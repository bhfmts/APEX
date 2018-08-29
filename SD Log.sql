DECLARE
MAIL VARCHAR2(32767);
LAST_HOUR SR_VOLUME%ROWTYPE;
L1_HOUR SR_VOLUME%ROWTYPE;
L2_HOUR SR_VOLUME%ROWTYPE;
L3_HOUR SR_VOLUME%ROWTYPE;
CURSOR SD_VOL
IS
SELECT * FROM (SELECT * FROM SR_VOLUME ORDER BY LOG_DATE DESC )SR_VOLUME WHERE ROWNUM <= 4
ORDER BY LOG_DATE DESC;

  incidId NUMBER;	
  incidTool VARCHAR2(32767);
  incidDescr VARCHAR2(32767);
  incidList VARCHAR2(32767);
  incidDate DATE;
  incidQty NUMBER;
  incidLastUpdate date;
  
  cursor openInc IS
select A.PROBLEM_ID, A.CREATION_DATE,A.LAST_UPDATE_DATE,A.TOOL,A.PROBLEM_DESCRIPTION, B.ASSOCIATED_INCIDENTS_QTY 
from PROBLEMS_MAIL A, INCIDENT_COUNTER B 
WHERE A.PROBLEM_ID=B.ID(+) and A.PROBLEM_DESCRIPTION <> 'TEST'
ORDER BY A.LAST_UPDATE_DATE DESC;

BEGIN
IF(SD_VOL%ISOPEN) THEN
 CLOSE SD_VOL;
END IF;
OPEN SD_VOL;
 FETCH SD_VOL INTO LAST_HOUR;
 FETCH SD_VOL INTO L1_HOUR;
 FETCH SD_VOL INTO L2_HOUR;
 FETCH SD_VOL INTO L3_HOUR;
CLOSE SD_VOL;

IF(openInc%ISOPEN) THEN
CLOSE openInc;
END IF;

OPEN openInc;

incidList := '<table class="bottomBorder" style="font-size:x-small;font-family:Arial;color:dimgray";><tr><th>ID</th><th>CREATION DATE<br>(CLT Santiago)</th><th>LAST UPDATE<br>(CLT Santiago)</th><th>TOOL</th><th>DESCRIPTION</th><th>IMPACTED</th></tr>';

  LOOP
        FETCH openInc INTO incidId, incidDate, incidLastUpdate, incidTool, incidDescr, incidQty;
        EXIT WHEN openInc%NOTFOUND;
        incidList := incidList || '<tr><td>    ' || incidId || '   ';
        incidList := incidList || '</td><td>   ' ||  to_char(incidDate,'DD-MON-YYYY HH24:MI:SS') || '   ';
incidList := incidList || '</td><td>   ' ||  to_char(incidLastUpdate,'DD-MON-YYYY HH24:MI:SS') || '   ';
        IncidList := incidList || '</td><td>     ' || incidTool || ' ';
        incidList := incidList || '</td><td>    ' || incidDescr || '   ';
        incidList := incidList || '</td><td>    ' || incidQty || '   ';
  END LOOP;

incidList := incidList ||' </td></tr></table> ';

IF openInc%ROWCOUNT < 1

THEN 

incidList := '<i>There are not any created or updated problems</i><br><br>';

END IF;

CLOSE openInc;



MAIL:='<head><style type="text/css">
table.bottomBorder { border-collapse:collapse; }
table.bottomBorder td, table.bottomBorder th { border-bottom:1px dotted black;padding:5px; }
</style></head>
<table style="font-family:Arial;">
<tr><td>*****This notification is sent automatically every hour by the RapidSR ServiceDesk Monitor on call*****</td></tr>
<tr><td>&nbsp;</td></tr>
<tr><td style="font-size:x-small;font-weight:bold;"><li>AUTOMATION VOLUMES (Recent Hours):</li></td></tr><tr><td>&nbsp;</td></tr><tr><td>
<table class="bottomBorder" style="font-size:x-small;font-family:Arial;color:dimgray";>
<tr align="center"><th>DATE<br>(CLT Santiago)</th><th>ASR</th><th>WEB</th><th>TOTAL</th><th>INCIDENTS</th></tr>
<tr><td> ' || to_char(LAST_HOUR.V_DATE, 'DD-MON-YYYY HH24:MI')  || ' </td><td align="center"> ' || LAST_HOUR.V_ASR || ' </td><td align="center"> ' || LAST_HOUR.V_WEB || ' </td><td align="center"> ' || (LAST_HOUR.V_ASR+LAST_HOUR.V_WEB) || ' </td><td align="center"> ' || LAST_HOUR.V_INCIDENT || ' </td></tr>
<tr><td> ' || to_char(L1_HOUR.V_DATE, 'DD-MON-YYYY HH24:MI')  || ' </td><td align="center"> ' || L1_HOUR.V_ASR || ' </td><td align="center"> ' || L1_HOUR.V_WEB || ' </td><td align="center"> ' || (L1_HOUR.V_ASR+L1_HOUR.V_WEB) || ' </td><td align="center"> ' || L1_HOUR.V_INCIDENT || ' </td></tr>
<tr><td> ' || to_char(L2_HOUR.V_DATE, 'DD-MON-YYYY HH24:MI')  || ' </td><td align="center"> ' || L2_HOUR.V_ASR || ' </td><td align="center"> ' || L2_HOUR.V_WEB || ' </td><td align="center"> ' || (L2_HOUR.V_ASR+L2_HOUR.V_WEB) || ' </td><td align="center"> ' || L2_HOUR.V_INCIDENT || ' </td></tr>
<tr><td> ' || to_char(L3_HOUR.V_DATE, 'DD-MON-YYYY HH24:MI')  || ' </td><td align="center"> ' || L3_HOUR.V_ASR || ' </td><td align="center"> ' || L3_HOUR.V_WEB || ' </td><td align="center"> ' || (L3_HOUR.V_ASR+L3_HOUR.V_WEB) || ' </td><td align="center"> ' || L3_HOUR.V_INCIDENT || ' </td></tr>
</table></td></tr>
<tr><td>&nbsp;</tr></td>
<tr><td style="font-size:x-small;font-weight:bold;"><li>SUMMARY OF LAST INCIDENTS & PROBLEMS:</li></td></tr><tr><td>&nbsp;</td></tr>
<tr><td>
<table style="font-size:x-small;font-family:Arial;color:dimgray;"><tr><td>
' || LAST_HOUR.OBS_P_REPORT || ' </td></tr></table>
<tr><td>&nbsp;</tr></td>
<tr><td style="font-size:x-small;font-weight:bold;"><li>OBSERVATIONS ABOUT AUTOMATION METRICS:</li></td></tr><tr><td>&nbsp;</td></tr>
<tr><td>
<table style="font-size:x-small;font-family:Arial;color:dimgray";><tr><td>
' || LAST_HOUR.OBS_PRO_INC || ' </td></tr></table>
<tr><td>&nbsp;</tr></td>
<tr><td style="font-size:x-small;font-weight:bold"><li>PROBLEMS CREATED OR UPDATED IN THE LAST 24 HOURS:</li></td></tr><tr><td>&nbsp;</td></tr>
<tr><td><table style="font-size:x-small;font-family:Arial;color:dimgray";><tr><td> ' || incidList || ' </td></tr></td></tr>
</table></tr></td><tr><td>&nbsp;</tr></td><tr><td>&nbsp;</tr></td><tr><td>Regards,
<br>RapidSR ServiceDesk Monitor.<br><tr><td><br><a href=https://apex.oraclecorp.com/pls/apex/f?p=11922:50:2139675581898:::::>RapidSR SD App</a></td></tr></tr></td>
</tr></td></table>';

APEX_MAIL.send(
p_to =>  'micc_service_desk_cl_grp@oracle.com',
p_from => :APP_USER,
p_body => 'SD_HOURLY_LOG',

p_body_html => MAIL,

p_SUBJ => 'Hourly ServiceDesk Log: ' || to_char(LAST_HOUR.V_DATE,'DD-MON-YYYY HH24:MI') || ' (CLT Santiago)',
p_cc => NULL,
p_bcc => NULL ,
p_replyto => 'micc_service_desk_cl_grp@oracle.com'

);


END;