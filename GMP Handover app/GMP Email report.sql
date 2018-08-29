DECLARE
    
    l_body      CLOB;
    l_body_html CLOB;
	l_workspace_id number;
	AlertsAddress clob;
	MissingAlerts clob;
	FutureAlerts clob;
	HandOver clob;	
	Engineers clob;
	current_engineer number;
	next_engineer number;
	first_name1 varchar2(50);
	last_name1 varchar2(50);
	first_name2 varchar2(50);
	last_name2 varchar2(50);
	
	
	cursor cAlertsAddress IS select alert_id, device_name,  summary, myhelp_ticket, creation_date, next_due_date, action_taken, next_action  
	from NETSEC_EOTD
where next_due_date  between  sysdate + 330/1440  and  sysdate + 571/1440 order by CREATION_DATE DESC;

	cursor cMissingAlerts IS select alert_id, device_name,  summary, myhelp_ticket, creation_date, next_due_date, action_taken, next_action
	from NETSEC_EOTD
	where next_due_date  < sysdate + 330/1440 order by CREATION_DATE DESC;
	
	cursor cFutureAlerts IS select alert_id, device_name,  summary, myhelp_ticket, creation_date, next_due_date, action_taken, next_action  
	from NETSEC_EOTD
where next_due_date  >=  sysdate + 570/1440 order by CREATION_DATE DESC;


	AA cAlertsAddress%rowtype;
	MA cMissingAlerts%rowtype;
	FA cFutureAlerts%rowtype;

BEGIN
   l_workspace_id := apex_util.find_security_group_id (p_workspace => 'CIT-CSCOE-PROD');
apex_util.set_security_group_id (p_security_group_id => l_workspace_id);

SELECT CURRENT_ENGINEER INTO CURRENT_ENGINEER
FROM (SELECT CURRENT_ENGINEER FROM NETSEC_EOTD_HO ORDER BY CREATION_DATE DESC) 
WHERE rownum = 1;	

SELECT NEXT_ENGINEER INTO NEXT_ENGINEER
FROM (SELECT NEXT_ENGINEER FROM NETSEC_EOTD_HO ORDER BY CREATION_DATE DESC) 
WHERE rownum = 1;

select firstname into first_name1 from iss_analyst
where analystid = current_engineer;
select lastname into last_name1 from iss_analyst
where analystid = current_engineer;

select firstname into first_name2 from iss_analyst
where analystid = next_engineer;
select lastname into last_name2 from iss_analyst
where analystid = next_engineer;


HandOver := '<html><head>
<style>
td, p, th {
    font-size: 14px;
}
</style>
</head>
<body>
<table border="1" cellpadding="1" cellspacing="1" height="200" width="220">
	<tbody>
		<tr>
			<td bgcolor="A5A5A5">Totally closed Myhelp tickets:</td>
			<td bgcolor="A5A5A5">'|| :P225_TOTAL_CLOSED ||'</td>
		</tr>
		<tr>
			<td bgcolor="A5A5A5">Totally unassigned Myhelp tickets:</td>
			<td bgcolor="A5A5A5">'|| :P225_TOTAL_UNASSIGNED ||'</td>
		</tr>
		<tr>
			<td>Unassigned Red Alerts:</td>
			<td>'|| :P225_UNASSIGNED_RED_ALERTS ||'</td>
		</tr>
		<tr>
			<td>Unassigned Orange alerts:</td>
			<td>'|| :P225_UNASSIGNED_ORANGE_ALERTS ||'</td>
		</tr>
	</tbody>
</table>
</body>
</html>';

Engineers := '
<html>
<body>
<head>
<style>
td,  {
    font-size: 14px;
}
</style>
</head>
<table bgcolor="67AFD8" border="1" cellpadding="1" cellspacing="1" height="117" width="340">
	<tbody>
		<tr>
			<td>Prepared by:</td>
			<td>'|| first_name1 ||'  '||last_name1||' </td>
		</tr>
		<tr>
			<td>Handover engineer:</td>
			<td>'|| first_name2 ||'  '||last_name2||'</td>
		</tr>
	</tbody>
</table>
</body>
';

OPEN cAlertsAddress;
	
AlertsAddress := '<html><head>
<style>
th, td, p  {
    font-size: 14px;
}
</style>
</head>

<body>
<p>Current alerts</p>

<table border=1 cellpadding=10>
<tr>
	<th bgcolor="FFC000">Alert ID</th>
	<th bgcolor="FFC000">Device name</th>
	<th bgcolor="FFC000">Description</th>
	<th bgcolor="FFC000">MyHelp Ticket</th>
	<th bgcolor="FFC000">Creation date(IST)</th>
	<th bgcolor="FFC000">Next Due Date(IST)</th>
	<th bgcolor="FFC000">Action taken</th>
	<th bgcolor="FFC000">Next Action</th>
</tr>';

Loop

FETCH cAlertsAddress INTO AA;
 EXIT WHEN cAlertsAddress%NOTFOUND;
         AlertsAddress := AlertsAddress || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:53:::NO::P53_ALERT_ID:'||
		aa.ALERT_ID||'>' || aa.ALERT_ID|| ''||  '';
		AlertsAddress := AlertsAddress || '</td><td>    ' || aa.DEVICE_NAME|| '   ';
		AlertsAddress := AlertsAddress || '</td><td>    ' || aa.SUMMARY || '   ';
        AlertsAddress := AlertsAddress || '</td><td>    ' || aa.MYHELP_TICKET || '   ';
		AlertsAddress := AlertsAddress || '</td><td>    ' || to_char(aa.CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS')|| '   ';
  		AlertsAddress := AlertsAddress || '</td><td>    ' || to_char(aa.NEXT_DUE_DATE,'DD-MON-YYYY HH24:MI:SS')|| '   ';
		AlertsAddress := AlertsAddress || '</td><td>    ' || aa.ACTION_TAKEN || '   ';
		AlertsAddress := AlertsAddress || '</td><td>    ' || aa.NEXT_ACTION || '   ';
	
				      END LOOP; 
			  
AlertsAddress := AlertsAddress ||' </td></tr></table></body></html> ';

IF cAlertsAddress%ROWCOUNT < 1

THEN 

AlertsAddress := '<p>Current Alerts<br><i>No Current Alerts</i></p>';

END IF;

CLOSE cAlertsAddress;
-- END cAlertsAddress



-- BEGIN SENSOR ISSUES FETCH
OPEN cMissingAlerts;
	
MissingAlerts := '
<html>
<head>
<style>
th, td, p  {
    font-size: 14px;
}
</style>
</head>
<body> 
<p><font color="red">Missed Alerts</font></p>
</head>
  

<table border=1 cellpadding=10>
<tr>
	<th bgcolor="FFC000"><font color="red">Alert ID</font></th>
	<th bgcolor="FFC000"><font color="red">Device name</font></th>
	<th bgcolor="FFC000"><font color="red">Description</font></th>
	<th bgcolor="FFC000"><font color="red">MyHelp Ticket</font></th>
	<th bgcolor="FFC000"><font color="red">Creation date(IST)</font></th>
	<th bgcolor="FFC000"><font color="red">Next Due Date(IST)</font></th>
	<th bgcolor="FFC000"><font color="red">Action taken</font></th>
	<th bgcolor="FFC000"><font color="red">Next Action</font></th>
</tr>';

Loop

FETCH cMissingAlerts INTO MA;
 EXIT WHEN cMissingAlerts%NOTFOUND;
         MissingAlerts := MissingAlerts || '<tr><td><font color="red">    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:53:::NO::P53_ALERT_ID:'||
ma.ALERT_ID||'>' || ma.ALERT_ID|| ''||  '';
          MissingAlerts := MissingAlerts || '</font></td><td><font color="red">    ' || ma.DEVICE_NAME || '   ';
        MissingAlerts := MissingAlerts || '</font></td><td><font color="red">    ' || ma.SUMMARY || '   ';
		MissingAlerts := MissingAlerts || '</font></td><td><font color="red">    ' || ma.MYHELP_TICKET|| '   ';
		MissingAlerts := MissingAlerts || '</font></td><td><font color="red">   ' ||to_char(ma.CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS') || '   ';
		 MissingAlerts := MissingAlerts || '</font></td><td><font color="red">    ' || to_char(ma.NEXT_DUE_DATE, 'DD-MON-YYYY HH24:MI:SS')|| '   ';
		 MissingAlerts := MissingAlerts || '</font></td><td><font color="red">    ' || ma.ACTION_TAKEN|| '   ';
		 MissingAlerts := MissingAlerts || '</font></td><td><font color="red">    ' || ma.NEXT_ACTION|| '   ';
				      END LOOP; 
			  
MissingAlerts := MissingAlerts ||' </font></td></tr></table></body></html> ';

IF cMissingAlerts%ROWCOUNT < 1

THEN 

MissingAlerts := '<p>Missed Alerts<br><i>No Missed Alerts</i></p>';

END IF;

CLOSE cMissingAlerts;
-- END cMissingAlerts

OPEN cFutureAlerts;
	
FutureAlerts := '<html><head>
<style>
td, p, th {
    font-size: 14px;
}
</style>
</head>
</head>
<body>

<br>

<p>Future Alerts</p>

<table border=1 cellpadding=10>
<tr>
	<th bgcolor="FFC000">Alert ID</th>
	<th bgcolor="FFC000">Device name</th>
	<th bgcolor="FFC000">Description</th>
	<th bgcolor="FFC000">MyHelp Ticket</th>
	<th bgcolor="FFC000">Creation date(IST)</th>
	<th bgcolor="FFC000">Next Due Date(IST)</th>
	<th bgcolor="FFC000">Action taken</th>
	<th bgcolor="FFC000">Next Action</th>
</tr>';


Loop

FETCH cFutureAlerts INTO FA;
 EXIT WHEN cFutureAlerts%NOTFOUND;
         FutureAlerts := FutureAlerts || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:53:::NO::P53_ALERT_ID:'||
		FA.ALERT_ID||'>' || FA.ALERT_ID|| ''||  '';
		FutureAlerts := FutureAlerts || '</td><td>    ' || FA.DEVICE_NAME|| '   ';
		FutureAlerts := FutureAlerts || '</td><td>    ' || FA.SUMMARY || '   ';
        FutureAlerts := FutureAlerts || '</td><td>    ' || FA.MYHELP_TICKET || '   ';
		FutureAlerts := FutureAlerts || '</td><td>    ' || to_char(FA.CREATION_DATE, 'DD-MON-YYYY HH24:MI:SS')|| '   ';
  		FutureAlerts := FutureAlerts || '</td><td>    ' || to_char(FA.NEXT_DUE_DATE,'DD-MON-YYYY HH24:MI:SS')|| '   ';
		FutureAlerts := FutureAlerts || '</td><td>    ' || FA.ACTION_TAKEN || '   ';
		FutureAlerts := FutureAlerts || '</td><td>    ' || FA.NEXT_ACTION || '   ';
	
				      END LOOP; 
			  
FutureAlerts := FutureAlerts ||' </td></tr></table></body></html> ';

IF cFutureAlerts%ROWCOUNT < 1

THEN 

FutureAlerts := '<p>Future Alerts<br><i>No Future Alerts</i></p>';

END IF;

CLOSE cFutureAlerts;



 l_body := 'EOTD Report';
 l_body_html := ''|| Engineers ||' <br> '|| HandOver ||' <br> '|| AlertsAddress || ' <br> '|| MissingAlerts || ' <br> ' || FutureAlerts ||'' ;
 

-- END TO FETCH

/* SEND EMAIL FUNCTION */
      apex_mail.send(
     p_to        => 'cit_network_operations_ww_grp@oracle.com',
     p_from      => 'cit_network_operations_ww_grp@oracle.com',
     p_cc        => '',
     p_body      => l_body,
     p_body_html => l_body_html,
     p_subj      => 'GMP Handover',
      p_bcc => '',
      p_replyto => NULL
	 );
/* END SEND EMAIL FUNCTION */



END;
