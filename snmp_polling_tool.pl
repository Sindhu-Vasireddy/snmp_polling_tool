#!/usr/bin/python
import time
from easysnmp import Session,EasySNMPTimeoutError,EasySNMPUnknownObjectIDError,EasySNMPNoSuchInstanceError
#from decimal import Decimal, getcontext
import sys
nt=0
timedout=0
SNMPCOUNTERTYPE=[]
def countervalue():
    global timedout
    global nt
    global SNMPCOUNTERTYPE
    global x
    global y
    a=(sys.argv[1]).rsplit(":",1)
    session=Session(hostname=a[0],community=a[1],timeout=1,version=2,retries=1)

    oid_sysuptime=['.1.3.6.1.2.1.1.3.0']
    oid=sys.argv[4:]
    oid_sysuptime.extend(oid)

    if oid_sysuptime:
        try:
           description=session.get(oid_sysuptime)
           c=[d.value for d in description]
         
           for d in description:
              if d.snmp_type == 'NOSUCHINSTANCE':
                 raise EasySNMPNoSuchInstanceError
              else:
                 SNMPCOUNTERTYPE.append(str(d.snmp_type))             
           oid_value=[float(i) for i in c]
           oid_value[0]=oid_value[0]/float(100)
        
        except (EasySNMPTimeoutError,EasySNMPNoSuchInstanceError):
           nt=nt+1
           oid_value=[]
 
    timedout=nt
    return oid_value

if __name__=='__main__':
   obj=[]
   tm = 1/float(sys.argv[2])
   samplenum=int(sys.argv[3])
   loop=0
   if int(sys.argv[3])==-1:
      samplenum=float("inf")
   while loop<samplenum+timedout+1:
       prc1 = time.time()
       obj1=countervalue()
   
       rate_final=[]    
       if obj and obj1:
          intersampletime=round(prc1-next,1)
          rate=[(i-j)/float(intersampletime) for i,j in zip(obj1[1:],obj[1:])]
          for rt in rate:
              if rt>=0:
                 rate_final.append(int(rt))
              elif rt<0:
                 if SNMPCOUNTERTYPE[rate.index(rt)+1]=='COUNTER':
                    rt=int(rt+(2**32/intersampletime))
                 elif SNMPCOUNTERTYPE[rate.index(rt)+1]=='COUNTER64':
                    rt=int(rt+(2**64/intersampletime))
                 rate_final.append(rt)
          ratefinal_output="|".join(map(str,rate_final))
          print("{}|{}".format(int(prc1),ratefinal_output))     
       if obj1:
         obj=obj1
       else:
         pass
       loop+=1
       next = prc1
       prc2 = time.time()
       time.sleep(abs(tm-prc2+prc1))
       if tm-prc2+prc1>0:
          time.sleep(abs(tm-prc2+prc1))
       else:
          pass