"""Analyze capture_uart.ps1 JSONL without sending commands to hardware.
Rates use host receive times; counters are differentiated within one session.
"""
import argparse, json, re, statistics
from pathlib import Path

def dist(values):
    if not values: return {'n': 0}
    a=sorted(values)
    def q(p):
        pos=(len(a)-1)*p; lo=int(pos); hi=min(lo+1,len(a)-1)
        return a[lo]+(a[hi]-a[lo])*(pos-lo)
    return dict(n=len(a),mean=statistics.mean(a),min=a[0],median=q(.5),p95=q(.95),max=a[-1])

def analyze(folder, start=5, end=None):
    report={'folder':folder.name,'window_seconds':[start,end], 'ports':{},
      'limitations':['Host receive timestamps include UART buffering and scheduling jitter.',
      'Counter deltas are per-board intervals, not a synchronized end-to-end loss estimate.',
      'NAV dropped counts source-side frame discard; it is not Ethernet packet loss.',
      'FACE timing is firmware inference duration, not button-to-feedback latency.',
      'Snapshot last_us values are not per-frame latency samples.',
      'Running firmware identity is user-reported current SD release, not read-back attestation.']}
    for path in sorted(folder.glob('serial_*.jsonl')):
        rows=[json.loads(x) for x in path.read_text(encoding='utf-8-sig').splitlines() if x.strip()]
        rows=[r for r in rows if r['seconds']>=start and (end is None or r['seconds']<=end)]
        streams={}; timings=[]; accesses=[]; faces=[]; live=[]; triggers=[]; failures=[]
        pending_trigger=None; event_pairs=[]; unmatched_triggers=[]
        for r in rows:
            s=r['text'].strip('\x00\r\n'); t=r['seconds']
            vals=dict(re.findall(r'(\w+)=([^\s;]+)',s))
            for marker in ('ONE_WAY_NAV','ONE_WAY_AX','NET','NET_TX'):
                if s.startswith(marker+' '): streams.setdefault(marker,[]).append((t,vals))
            if s.startswith('FACE timing '): timings.append({k:int(v) for k,v in vals.items()})
            if s.startswith('FACE result '): faces.append({'seconds':t,**vals})
            if s.startswith('ACCESS result '):
                accesses.append({'seconds':t,**vals})
                if pending_trigger is not None:
                    event_pairs.append({'trigger_seconds':pending_trigger,'result_seconds':t,
                        'elapsed_seconds':t-pending_trigger,'frame':vals.get('frame'),'grant':vals.get('grant')})
                    pending_trigger=None
            if s.startswith('LIVE FINAL '): live.append({'seconds':t,**vals})
            if s.startswith('SCREEN capture trigger '):
                triggers.append(t)
                if pending_trigger is not None:unmatched_triggers.append(pending_trigger)
                pending_trigger=t
            if any(x in s for x in ('FATAL:','FACE inference failed','SCREEN capture rejected','LIVE timeout','LIVE sequence timeout')):
                failures.append({'seconds':t,'text':s})
        if pending_trigger is not None:unmatched_triggers.append(pending_trigger)
        output={'streams':{},'face_timing_us':{k:dist([r[k] for r in timings if k in r]) for k in ('detect_us','embed_us','total_us')},
                'face_results':faces,'access_results':accesses,'live_results':live,'capture_trigger_seconds':triggers,'failures':failures}
        output.update(trigger_to_access_host_seconds=dist([x['elapsed_seconds'] for x in event_pairs]),
                      trigger_to_access_pairs=event_pairs,unmatched_capture_triggers=unmatched_triggers)
        for marker, seq in streams.items():
            first,last=seq[0],seq[-1]; elapsed=last[0]-first[0]
            sessions={v.get('session') for _,v in seq if 'session' in v}
            reset=len(sessions)>1
            deltas={}; rates={}
            counterkeys={'ONE_WAY_NAV':['copied','rectified','sent','aborted','dropped'],
                         'ONE_WAY_AX':['received','verified','submitted','result','hdmi','rejected','expired'],
                         'NET':['rx_dma','accepted','queue_full','qdrop','rx_recoveries','fcs','resource','overrun','ip_bad','udp_bad'],
                         'NET_TX':['recoveries','arp_stalls','udp_stalls','pool_stalls']}[marker]
            for k in counterkeys:
                vals=[int(v[k]) for _,v in seq if k in v]
                if len(vals)!=len(seq): continue
                if any(b<a for a,b in zip(vals,vals[1:])): reset=True
                deltas[k]=vals[-1]-vals[0]
            if not reset and elapsed>0: rates={k:v/elapsed for k,v in deltas.items()}
            output['streams'][marker]={'samples':len(seq),'first_seconds':first[0],'last_seconds':last[0],
              'elapsed_seconds':elapsed,'session_changes_or_counter_decrease':reset,
              'first':first[1],'last':last[1],'delta':deltas,'rate_per_second':rates}
        report['ports'][rows[0]['port'] if rows else path.stem]=output
    return report

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('folder',type=Path);p.add_argument('--start',type=float,default=5)
    p.add_argument('--end',type=float);p.add_argument('--output',type=Path)
    a=p.parse_args(); text=json.dumps(analyze(a.folder,a.start,a.end),ensure_ascii=False,indent=2)
    if a.output:a.output.write_text(text+'\n',encoding='utf-8')
    else:print(text)
