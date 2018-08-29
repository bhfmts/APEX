DECLARE
    
    l_body      CLOB;
    l_body_html CLOB;
    to_month number;
	to_day number;

	escalated_offenses clob;
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
	where STATUS ='New';
	-- SHIFT = :P220_SHIFT and
	--to_char(LAST_MODIFIED_DATE, 'DD-Mon-YYYY') = :P220_SHIFT_DATE
	--AND
	
	cursor SENSOR_ISSUES_KNOWN IS select id, creation_date, device, comments, shift, created_by, last_modified_date, last_modified_by, status, failover_mode 
	from IDSIEM_SENSOR_ISSUES 
	where STATUS ='Known';
    -- SHIFT = :P220_SHIFT and
	
	--to_char(LAST_MODIFIED_DATE, 'DD-Mon-YYYY') = :P220_SHIFT_DATE
	--AND
	
	cursor Offenses_shift is select id, shift_date, shift, offense_id, description, analyst, status from IDSIEM_OFFENSES
	WHERE to_char(SHIFT_DATE, 'DD-Mon-YYYY') = :P220_SHIFT_DATE
	AND SHIFT = :P220_SHIFT;
	
	

		escalated ESCALATED_OFFENSES1%rowtype;
	sensor SENSOR_ISSUES_NEW%rowtype;
	sensor_known SENSOR_ISSUES_KNOWN%rowtype;
	Offenses1 Offenses_shift%rowtype;
	


BEGIN

SELECT id INTO lastID
FROM (SELECT id FROM IDSIEM_SHIFT_TURNOVER ORDER BY SHIFT_DATE DESC) 
WHERE rownum = 1;	
	
	
	
	
	
	-- BEGIN ESCALATED OFFENSES FETCH	
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

-- BEGIN SENSOR ISSUES FETCH

OPEN SENSOR_ISSUES_NEW;
	
sensors := '<table border=1 cellpadding=10><tr><th>ID</th><th>Creation Date</th><th>Device</th><th>Failover Mode</th><th>Comments</th><th>Shift</th><th>Created by</th><th>Last Modified Date</th><th>Last Modified By</th><th>Status</th></tr>';

Loop

FETCH SENSOR_ISSUES_NEW INTO sensor;
 EXIT WHEN SENSOR_ISSUES_NEW%NOTFOUND;
         sensors := sensors || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:188:::NO::P188_ID:'||
sensor.Id||'>' || sensor.Id|| ''||  '';
        sensors := sensors || '</td><td>    ' || sensor.CREATION_DATE || '   ';
        sensors := sensors || '</td><td>    ' || sensor.DEVICE || '   ';
		     sensors := sensors || '</td><td>    ' || sensor.failover_mode|| '   ';
		 sensors := sensors || '</td><td>    ' || sensor.COMMENTS|| '   ';
        sensors := sensors || '</td><td>    ' || sensor.SHIFT || '   ';
        sensors := sensors || '</td><td>    ' || sensor.CREATED_BY || '   ';
		 sensors := sensors || '</td><td>    ' || sensor.LAST_MODIFIED_DATE|| '   ';
        sensors := sensors || '</td><td>    ' || sensor.LAST_MODIFIED_BY || '   ';
        sensors := sensors || '</td><td>    ' || sensor.STATUS || '   ';
		
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
	
sensors_known := '<table border=1 cellpadding=10><tr><th>ID</th><th>Creation Date</th><th>Device</th><th>Failover Mode</th><th>Comments</th><th>Shift</th><th>Created by</th><th>Last Modified Date</th><th>Last Modified By</th><th>Status</th></tr>';

Loop

FETCH SENSOR_ISSUES_KNOWN INTO sensor_known;
 EXIT WHEN SENSOR_ISSUES_KNOWN%NOTFOUND;
         sensors_known := sensors_known || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:188:::NO::P188_ID:'||
sensor_known.Id||'>' || sensor_known.Id|| ''||  '';
        sensors_known := sensors_known || '</td><td>    ' || sensor_known.CREATION_DATE || '   ';
        sensors_known := sensors_known || '</td><td>    ' || sensor_known.DEVICE || '   ';
			  sensors_known := sensors_known || '</td><td>    ' || sensor_known.failover_mode|| '   ';
		 sensors_known := sensors_known || '</td><td>    ' || sensor_known.COMMENTS|| '   ';
        sensors_known := sensors_known || '</td><td>    ' || sensor_known.SHIFT || '   ';
        sensors_known := sensors_known || '</td><td>    ' || sensor_known.CREATED_BY || '   ';
		 sensors_known := sensors_known || '</td><td>    ' || sensor_known.LAST_MODIFIED_DATE|| '   ';
        sensors_known := sensors_known || '</td><td>    ' || sensor_known.LAST_MODIFIED_BY || '   ';
        sensors_known := sensors_known || '</td><td>    ' || sensor_known.STATUS || '   ';
		
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
 
<p>Hello Team, <br>
Please find the SIEM TO details.</p>

<p><b>NOTE: '|| :P220_COMMENTS ||' </b></p>
<p>Here are the details of the offenses worked during this shift:</p><br>

 <table border=1 cellpadding=10>

<tr>
<td>ID: </td>
<td>'|| lastID ||'</td>
</tr>

<tr>
<td>Date: </td>
<td>'|| :P220_SHIFT_DATE ||'</td>
</tr>

<tr>
<td>Shift: </td>
<td>'|| :P220_SHIFT ||'</td>
</tr>
 
<tr>
<td>Offenses generated: </td>
<td>'|| :P220_OFFENSE_GENERATED ||'</td>
</tr>

<tr>
<td>Offenses processed: </td>
<td>'|| :P220_OFFENSE_PROCESSED ||'</td>
</tr>

<tr>
<td>Last Offense: </td>
<td>'|| :P220_LAST_OFFENSE ||'</td>
</tr>

<tr>
<td>Comments: </td>
<td>'|| :P220_COMMENTS ||'</td>
</tr>

<tr>
<td>Created by: </td>
<td>'|| :P220_CREATED_BY ||'</td>
</tr>
</table>

<h2>Offenses:</h2><br>
'||Offenses ||'<br>

<h2>Escalated offenses:</h2><br>
'||escalated_offenses ||'<br>

<h2>New sensor issues: </h2>
<br> '|| sensors ||'

<h2>Known sensor issues: </h2>
<br> '|| sensors_known||'';




-- END TO FETCH

/* SEND EMAIL FUNCTION */
      apex_mail.send(
     p_to        => :app_user,
     p_from      => :app_user,
     p_cc        => '',
     p_body      => l_body,
     p_body_html => l_body_html,
     p_subj      => 'SIEM TO | Shift ' || :P220_SHIFT || ' | ' || :P220_SHIFT_DATE ||''   ,
      p_bcc => NULL,
      p_replyto => NULL
	 );
/* END SEND EMAIL FUNCTION */



END;