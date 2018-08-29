DECLARE
    
    l_body      CLOB;
    l_body_html CLOB;
    to_month number;
	to_day number;

	escalated_offenses clob;
	special_list clob;
	sensors clob;
	sensors_known clob;
	offenses clob;
	lastID number;
	
	
	cursor ESCALATED_OFFENSES1 is SELECT id, offense, SR, analyst, offense_description, start_date, source_ips, destination_ips,
 status, action_taken, escalated_by, closure_date, 
escalated_rm, shift, last_modified_date, last_modified_by, customer_name FROM IDSIEM_ESCALATED_OFFENSES
	WHERE to_char(start_date, 'DD-Mon-YYYY') = :P220_SHIFT_DATE
	AND SHIFT = :P220_SHIFT;
	
	
	cursor SENSOR_ISSUES_NEW IS select id, creation_date, device, comments, shift, created_by, last_modified_date, last_modified_by, status, failover_mode 
	from IDSIEM_SENSOR_ISSUES 
	where STATUS ='New'
order by creation_date desc;
	-- SHIFT = :P220_SHIFT and
	--to_char(LAST_MODIFIED_DATE, 'DD-Mon-YYYY') = :P220_SHIFT_DATE
	--AND
	
	cursor SENSOR_ISSUES_KNOWN IS select id, creation_date, device, comments, shift, created_by, last_modified_date, last_modified_by, status, failover_mode 
	from IDSIEM_SENSOR_ISSUES 
	where STATUS ='Known' 
order by creation_date desc;
    -- SHIFT = :P220_SHIFT and
	
	--to_char(LAST_MODIFIED_DATE, 'DD-Mon-YYYY') = :P220_SHIFT_DATE
	--AND
	
	cursor SPECIAL_INSTRUCTIONS IS select id, DESCRIPTION, EXPIRES_ON
	from IDSIEM_SPECIAL_INSTRUCTIONS;
	
	cursor Offenses_shift is select id, shift_date, shift, offense_id, description, analyst, status from IDSIEM_OFFENSES
	WHERE to_char(SHIFT_DATE, 'DD-Mon-YYYY') = :P220_SHIFT_DATE
	AND SHIFT = :P220_SHIFT;
	
	

		escalated ESCALATED_OFFENSES1%rowtype;
	sensor SENSOR_ISSUES_NEW%rowtype;
	sensor_known SENSOR_ISSUES_KNOWN%rowtype;
	Offenses1 Offenses_shift%rowtype;
	special SPECIAL_INSTRUCTIONS%rowtype;


BEGIN

SELECT id INTO lastID
FROM (SELECT id FROM IDSIEM_SHIFT_TURNOVER ORDER BY SHIFT_DATE DESC) 
WHERE rownum = 1;	
	
	
	
	
	
--BEGIN ESCALATED OFFENSES FETCH	
OPEN ESCALATED_OFFENSES1;
	
escalated_offenses := '<table border=1 cellpadding=10><tr><th>ID</th><th>Offense</th><th>SR</th><th>Analyst</th><th>Offense description</th><th>Start date</th><th>Source IPs</th><th>Destination IPs</th><th>Status</th><th>Action Taken</th>
<th>Escalated By</th><th>Closure Date</th><th>Escalated RM</th><th>Shift</th><th>Last Modified Date</th><th>Last Modified By</th><th>Customer Name</th></tr>';

Loop

FETCH ESCALATED_OFFENSES1 INTO escalated;
 EXIT WHEN ESCALATED_OFFENSES1%NOTFOUND;
         escalated_offenses := escalated_offenses || '<tr><td><a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:211:::NO::P211_ID:'||
escalated.Id||'>' || escalated.Id|| ''||  '';
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.offense || '   ';
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.SR || '   ';
		 escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.analyst|| '   ';
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.offense_description || '   ';
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.start_date || '   ';
		 escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.source_ips|| '   ';
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.destination_ips || '   ';
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.status || '   ';
		 escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.action_taken || '   ';
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.escalated_by || '   ';
     
if	escalated.closure_date is null then 
escalated_offenses := escalated_offenses || '</td><td> -  ';
else
	 escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.closure_date || '  ';
end if;		
 
if	escalated.escalated_rm is null then 
escalated_offenses := escalated_offenses || '</td><td> -  ';
else
escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.escalated_rm || '   ';
end if;	
        
		escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.shift || '   ';
		
if	escalated.last_modified_date is null then 
		escalated_offenses := escalated_offenses || '</td><td> -  ';
else
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.last_modified_date || '   ';
end if;
	
	escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.last_modified_by  || '   ';
        escalated_offenses := escalated_offenses || '</td><td>    ' || escalated.customer_name || '   ';
      END LOOP;
escalated_offenses := escalated_offenses ||' </td></tr></table> ';

IF ESCALATED_OFFENSES1%ROWCOUNT < 1

THEN 

escalated_offenses := '<i>There are not any created or updated problems</i><br><br>';

END IF;

CLOSE ESCALATED_OFFENSES1;
-- END ESCALATED OFFENSES FETCH


-- BEGIN SPECIAL FETCH

OPEN SPECIAL_INSTRUCTIONS;
	
special_list := '<table border=1 cellpadding=10><tr><th>ID</th><th>Description</th><th>Expires On</th></tr>';

Loop

FETCH SPECIAL_INSTRUCTIONS INTO special;
 EXIT WHEN SPECIAL_INSTRUCTIONS%NOTFOUND;
         special_list := special_list || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:170:::NO::P170_ID:'||
special.Id||'>' || special.Id|| ''||  '';
        special_list := special_list || '</td><td>    ' || special.description || '   ';
        special_list := special_list || '</td><td>    ' || special.Expires_on || '   ';
		     	
				      END LOOP; 
			  
special_list := special_list ||' </td></tr></table> ';

IF SPECIAL_INSTRUCTIONS%ROWCOUNT < 1

THEN 

special_list := '<i>There are not any sensor issue updates</i><br><br>';

END IF;

CLOSE special_instructions;
-- end special fetch


-- BEGIN SENSOR ISSUES FETCH
OPEN SENSOR_ISSUES_NEW;
	
sensors := '<table border=1 cellpadding=10><tr><th>ID</th><th>Creation Date</th><th>Device</th><th>Failover Mode</th><th>Comments</th></tr>';

Loop

FETCH SENSOR_ISSUES_NEW INTO sensor;
 EXIT WHEN SENSOR_ISSUES_NEW%NOTFOUND;
         sensors := sensors || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:188:::NO::P188_ID:'||
sensor.Id||'>' || sensor.Id|| ''||  '';
        sensors := sensors || '</td><td>    ' || sensor.CREATION_DATE || '   ';
        sensors := sensors || '</td><td>    ' || sensor.DEVICE || '   ';
		     sensors := sensors || '</td><td>    ' || sensor.failover_mode|| '   ';
		 sensors := sensors || '</td><td>    ' || sensor.COMMENTS|| '   ';
  		
				      END LOOP; 
			  
sensors := sensors ||' </td></tr></table> ';

IF SENSOR_ISSUES_NEW%ROWCOUNT < 1

THEN 

sensors := '<i>There are not any sensor issue updates</i><br><br>';

END IF;

CLOSE SENSOR_ISSUES_NEW;
-- END SENSOR ISSUES FETCH

-- BEGIN SENSOR ISSUES KNOWN FETCH

OPEN SENSOR_ISSUES_KNOWN;
	
sensors_known := '<table border=1 cellpadding=10><tr><th>ID</th><th>Creation Date</th><th>Device</th><th>NSM Server</th><th>Comments</th></tr>';

Loop

FETCH SENSOR_ISSUES_KNOWN INTO sensor_known;
 EXIT WHEN SENSOR_ISSUES_KNOWN%NOTFOUND;
         sensors_known := sensors_known || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:188:::NO::P188_ID:'||
sensor_known.Id||'>' || sensor_known.Id|| ''||  '';
        sensors_known := sensors_known || '</td><td>    ' || sensor_known.CREATION_DATE || '   ';
        sensors_known := sensors_known || '</td><td>    ' || sensor_known.DEVICE || '   ';
			  sensors_known := sensors_known || '</td><td>    ' || sensor_known.failover_mode|| '   ';
		 sensors_known := sensors_known || '</td><td>    ' || sensor_known.COMMENTS|| '   ';
  		
				      END LOOP; 
			  
sensors_known := sensors_known ||' </td></tr></table> ';

IF SENSOR_ISSUES_KNOWN%ROWCOUNT < 1

THEN 

sensors_known := '<i>There are not any sensor issue updates</i><br><br>';

END IF;

CLOSE SENSOR_ISSUES_KNOWN;
-- END SENSOR ISSUES KNOWN FETCH

-- BEGIN OFFENSES FETCH

OPEN Offenses_shift;
	
OFFENSES := '<table border=1 cellpadding=10><tr><th>ID</th><th>Shift Date</th><th>Shift</th><th>Offense Id</th><th>Description</th><th>Analyst</th><th>Status</th></tr>';

Loop

FETCH Offenses_shift INTO OFFENSES1;
 EXIT WHEN Offenses_shift%NOTFOUND;
         OFFENSES := OFFENSES || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:209:::NO::P209_ID:'||
OFFENSES1.Id||'>' || OFFENSES1.Id|| ''||  '';
        OFFENSES := OFFENSES || '</td><td>    ' || OFFENSES1.SHIFT_DATE || '   ';
        OFFENSES := OFFENSES || '</td><td>    ' || OFFENSES1.SHIFT || '   ';
		 OFFENSES := OFFENSES || '</td><td>    ' || OFFENSES1.OFFENSE_ID|| '   ';
        OFFENSES := OFFENSES || '</td><td>    ' || OFFENSES1.DESCRIPTION || '   ';
        OFFENSES := OFFENSES || '</td><td>    ' || OFFENSES1.ANALYST || '   ';
		 OFFENSES := OFFENSES || '</td><td>    ' || OFFENSES1.STATUS|| '   ';
    				      END LOOP; 
			  
OFFENSES := OFFENSES ||' </td></tr></table> ';

IF Offenses_shift%ROWCOUNT < 1

THEN 

OFFENSES := '<i>There are not offenses</i><br><br>';

END IF;

CLOSE Offenses_shift;
-- END OFFENSES FETCH

--BEGIN TO FETCH
 l_body := 'Test';
 l_body_html := '
<table align="center" border="0" cellpadding="0" cellspacing="0" frame="BOX" rules="NONE" style="cellpadding:0 cellspacing:0" width="615">
			<tbody>
				<tr>
					<td align="right" bgcolor="#FF0000" colspan="2" height="32">
						<img align="left" alt="Oracle
Corporation" height="30" src="http://www.steadmanusa.com/orared.gif" width="123" /><span style="font-size:17px;font-family: Arial, Helvetica,
text-align:right; sans-serif;color: #FFFFFF;font-style:
italic;"> <b>Cloud IT Security Notification</b></span></td>
				</tr>
				<tr>
					<td colspan="2">
						&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2">
						<div align="left">
							<div class="imagefile">
								<b><span style="font-size:18px;font-family: Arial, Helvetica, sans-serif;color: #003366;font-style: italic;"><img align="right" alt="CIT" border="0" height="71" src="http://img842.imageshack.us/img842/508/v072.png" width="122" /></span></b></div>
							<b><span style="font-size:18px;font-family: Arial, Helvetica, sans-serif;color: #003366;font-style: bold;">Cloud IT NSOC<br />
							SIEM Shift Summary Report</span></b></div>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<div align="center">
							&nbsp;</div>
					</td>
				</tr>
			</tbody>
		</table>
		
	
		<table align="center" border="0" cellpadding="0" cellspacing="0" frame="BOX" rules="NONE" style="cellpadding:0 cellspacing:0" width="615">
			<tbody>
				<tr>
					<td colspan="2">
						<div align="center">
							<br />
							<h3><u>Shift Summary.</u></h3>
							<table align="center" border="1" cellpadding="2" cellspacing="1" width="580">
								<tbody>
									
									<tr>
										<td align="right" width="25%">
											<b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Date:</span></b></td>
										<td>
											<span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">'|| :P220_SHIFT_DATE ||'</span></td>
									</tr>
									<tr>
										<td align="right" width="38%">
											<b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Shift:</span></b></td>
										<td>
											<span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">'|| :P220_SHIFT ||'</span></td>
									</tr>
									<tr>
										<td align="right" width="20%">
											<b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Offenses generated</span></b></td>
										<td>
											<span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">'|| :P220_OFFENSE_GENERATED ||'</span></td>
									</tr>
									<tr>
										<td align="right" width="20%">
											<b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Offenses processed:</span></b></td>
										<td>
											<span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">'|| :P220_OFFENSE_PROCESSED ||'</span></td>
									</tr>
									<tr>
										<td align="right" width="25%">
											<b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Last offense:</span></b></td>
										<td>
											<span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">'|| :P220_LAST_OFFENSE ||'</span></td>
									</tr>
									<tr>
										<td align="right" width="25%">
											<b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Comments:</span></b></td>
										<td>
											<span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">'|| :P220_COMMENTS ||'</span></td>
									</tr>
									<tr>
										<td align="right" width="20%">
											<b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Created by:</span></b></td>
										<td>
											<span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">'|| :P220_CREATED_BY ||'</span></td>
									</tr>
									
								</tbody>
							</table>
						</div>
					</td>
				</tr>
			</tbody>
	  </table>
				<br>
				<center><h3><u>Special Instructions.</u></h3>
             '|| special_list ||'</center>
			
			<h3><u>New sensor issues.</u></h3>
'|| sensors ||'

<h3><u>Known sensor issues</u></h3>
'|| sensors_known||' <br>
					<tr>
					<td colspan="2">
						<span style="font-family: Arial, Helvetica, sans-serif; font-size: 14px;">Further details can be found <a href="https://apex.oraclecorp.com/pls/apex/f?p=1648:219">here</a><br />
							<span style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; color:red;"><b>NOTE:</b> You must be logged in to the Oracle Network to view the full incident.</span></span>
					</td>
				</tr>
				
			<br>
				<tr>
					<td colspan="2">
						<span style="font-size:14px;font-family: Arial, Helvetica, sans-serif;">For more information or feedback, please contact the team at <a href="mailto:citnetsec-ids_us_grp@oracle.com">citnetsec-ids_us_grp@oracle.com</a><br><br>
						Thank You,<br>
						IDS/SIEM Team.</span></td>
				</tr>
				<tr>
					<td colspan="2">
						<hr size="1" width="100%" />
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<div align="center">
							<span style="font-family: Arial, Helvetica, sans-serif; font-size: 10px;">ORACLE CONFIDENTIAL - INTERNAL<br />
							</span></div>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<hr align="left" size="2" width="100%" />
					</td>
				</tr>
				
				<tr>
					<td colspan="2">
						<div class="imagefile">
							<img alt="SOFTWARE HARDWARE COMPLETE" border="0" height="42" src="http://www.steadmanusa.com/HardwareandSoftware.gif" width="140" /></div>
					</td>
				</tr>
				
				<tr>
					<td colspan="2" height="2" valign="bottom">
						<hr align="left" size="2" width="100%" />
					</td>
				</tr>
				<tr>
					<td width="276">
						<span style="font-family: Arial, Helvetica, sans-serif; font-size: 9px; padding-top:0px; margin-top:0px;">Copyright 2013, Oracle Corporation<br />
						and/or its affiliates. All rights reserved</span></td><br>
					
			<span style="font-family: Arial, Helvetica, sans-serif; font-size: 9px; color:black;">Email sent at: '|| to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')  ||' GMT by: '||:APP_USER ||'</span></p>
			
			';

-- END TO FETCH

/* SEND EMAIL FUNCTION */
      apex_mail.send(
     p_to        => 'citnetsec-ids_us_grp@oracle.com',
     p_from      => 'citnetsec-ids_us_grp@oracle.com',
     p_cc        => '',
     p_body      => l_body,
     p_body_html => l_body_html,
     p_subj      => 'SIEM TO | Shift ' || :P220_SHIFT || ' | ' || :P220_SHIFT_DATE ||''   ,
      p_bcc => NULL,
      p_replyto => NULL
	 );
/* END SEND EMAIL FUNCTION */



END;