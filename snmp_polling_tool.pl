#!/usr/bin/python
import time
from easysnmp import Session,EasySNMPTimeoutError
import sys
nt=0
timedout=0
def countervalue():
    global timedout #Declaring a global variable to be used in the function definition.
    global nt
    a=(sys.argv[1]).rsplit(":",1) #Splitting up the community name from <IPaddress:PortNumber:community>.
    session=Session(hostname=a[0],community=a[1],timeout=0.0001,version=2) #Start a session with the sub-agent.

    oid_sysuptime=['.1.3.6.1.2.1.1.3.0'] #SYSUPTIME OID
    oid=sys.argv[4:] #Fetching other OIDs entered on the console
    oid_sysuptime.extend(oid) #Appending these OIDs from the console to the list containing the SYSUPTIME OID

    for str in sys.argv[4:]: #For each OID in the list try the following and if exceptions arise follow except block.
        try:
           description=[session.get(value) for value in oid_sysuptime] #Obtain the response for each OID in the list.
           c=[d.value for d in description] #From the response received section out the counter values.
           oid_value=[float(i) for i in c] #Convert the counter values from string to integer and store in a list.
           oid_value[0]=oid_value[0]/float(100) #Since the counter value of SYSUPTIME indicates time in hundreth of a second.
        except EasySNMPTimeoutError:
           nt=nt+1 #Counter for counting the number of timeouts in total from all the OIDs collectively each time a new sample is called.
           oid_value=[] #Make the list described above empty each time a timeout occurs.
    timedout=nt/int(len(sys.argv[4:])) #Divide the total number of timeouts by total number of OIDs requested for, to get number of timeouts per OID. 
    return oid_value #Return the list. 

if __name__=='__main__':
   obj=countervalue() #Call the function and assign the returned value of the function to a variable.
   loop=0 #Initialise the 'loop' variable to zero.
   while loop<int(sys.argv[3])+timedout: #If a timeout is encountered keep running the loop until the requested number of samples are called.
       time.sleep(1/float(sys.argv[2])) #Sleep for a duration equal to the sampling interval before a new list of counter values is called.
       ts=1/float(sys.argv[2]) #Calculating the sampling interval from the requested sampling frequency.
       obj1=countervalue() #A new list with counter values obtained after every 1/f(Hz).
       rate_final=[] #Initialising a list to collect all the rates calculated.
       lts=[] #Initialising another list to hold the last successful list of counter values in case of timeouts.

       if not obj or not obj1: #If either of the lists is empty:
          out="TIMEOUT" #Store TIMEOUT in a variable.
          rate_final.append(out) #Then, append the string TIMEOUT to the rate_final list.
          if obj and not obj1: #If the previous list was not empty but the current list is, then store the last successful timestamp into list lts.
             lts=obj[0] 
          else: 
             lts=obj #If there have been no successful samples then store obj as it is into lts which is an emtpy list from the exception in the function definition.
       if obj and obj1: #If none of the samples are empty lists then calculate the rate as follows:
          lts=obj[0] #Stores the last successful timestamp.
          intersampletime=(float(obj1[0])-float(obj[0])) #Calculate the intersampletime from the SYSUPTIME counter values.
          if intersampletime<0: #If the intersample time is less than zero, it may indicate a restart. So, from the last successful sampletime and the time elapsed from that point, calculate the current time.
             intersampletime=timedout*ts+ts
          else:
             rate=[(i-j)*8/float(intersampletime) for i,j in zip(obj1[1:],obj[1:])] #Calculate the rate for each of the counter values in the list.
          for rt in rate:
              if rt>=0: #If the rate is greater than zero append it to the list rate_final.
                 rate_final.append(rt)
              elif rt<0: #If the rate is negative, then a counter wrap has occurred so for a 32-bit counter do the following.
                 rt=rt+(2**32/intersampletime)
                 if rt<0: #If the rate is negative even after the correction then it must be a 64-bit counter then do the following.
                    rt=rt-(2**32/intersampletime)+(2**64/intersampletime)
                 rate_final.append(rt) #And, finally append the rate to rate_final list.

       if obj1: #If there have been continuous timeouts until the current sample collected.
         obj=obj1
       else:
         pass

       loop+=1 #Run the loop until the required number of samples are collected.

       ratefinal_output="|".join(map(str,rate_final)) #Join the list elements by a '|'.
       print "{}|{}".format(lts,ratefinal_output) #Final Output to be displayed to stdout in the format desired.



