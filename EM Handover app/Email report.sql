	DECLARE    
		l_body      CLOB;
		l_body_html CLOB;
		l_workspace_id number;
		ImportantLinks clob;
		AlertsAddress clob;
		ImportantInfo clob;
		HeadingReport clob;
		ALERTS clob;
		MissingAlerts clob;
		FutureAlerts clob;
		Engineers clob;
		current_engineer number;
		next_engineer number;
		first_name1 varchar2(50);
		last_name1 varchar2(50);
		first_name2 varchar2(50);
		last_name2 varchar2(50);
		
		cursor cAlerts IS select ID, ALERT_TYPE,TOTAL_ALERTS, ACK_IN_SHIFT, CLOSED, UNACK, ID_HANDOVER from NETSEC_EM_ALERTS
		WHERE ID_HANDOVER = :P378_ID;	

		cursor cImportantInfo IS select ID, DESCRIPTION, CREATION_DATE, NEXT_DUE_DATE, ACTION_TAKEN, NEXT_ACTION  
		from NETSEC_EM_IMPORTANT_INFO where next_due_date  >= sysdate + 330/1440;

	cursor cAlertsAddress IS select alert_id, device_name, DESCRIPTION, EM_INCIDENT_ID, creation_date, next_due_date, action_taken, next_action  
		from NETSEC_EM_INCIDENTS
	where next_due_date  between  sysdate + 330/1440  and  sysdate + 571/1440 order by CREATION_DATE DESC;

		cursor cMissingAlerts IS select alert_id, device_name, DESCRIPTION, EM_INCIDENT_ID, creation_date, next_due_date, action_taken, next_action
		from NETSEC_EM_INCIDENTS
		where next_due_date  < sysdate + 330/1440 order by CREATION_DATE DESC;
		
		cursor cFutureAlerts IS select alert_id, device_name, DESCRIPTION, EM_INCIDENT_ID, creation_date, next_due_date, action_taken, next_action  
		from NETSEC_EM_INCIDENTS
	where next_due_date  >=  sysdate + 570/1440 order by CREATION_DATE DESC;
		ii cImportantInfo%rowtype;
		aatt cAlerts%rowtype;
		AA cAlertsAddress%rowtype;
		MA cMissingAlerts%rowtype;
		FA cFutureAlerts%rowtype;
	BEGIN
	   l_workspace_id := apex_util.find_security_group_id (p_workspace => 'CIT-CSCOE-PROD');
	apex_util.set_security_group_id (p_security_group_id => l_workspace_id);

/*	SELECT PREPARED_BY INTO CURRENT_ENGINEER
	FROM NETSEC_EM_HANDOVER WHERE  PREPARED_BY = :P378_PREPARED_BY;
	

	SELECT NEXT_ENGINEER INTO NEXT_ENGINEER
	FROM NETSEC_EM_HANDOVER WHERE NEXT_ENGINEER = :P378_NEXT_ENGINEER;


	select firstname into first_name1 from iss_analyst
	where analystid = current_engineer;
	select lastname into last_name1 from iss_analyst
	where analystid = current_engineer;

	select firstname into first_name2 from iss_analyst
	where analystid = next_engineer;
	select lastname into last_name2 from iss_analyst
	where analystid = next_engineer;
	
	*/
	
	HeadingReport:=' <table border="0" cellpadding="0" cellspacing="0" frame="BOX" rules="NONE" style="cellpadding:0 cellspacing:0" width="615">
			<tbody>
				<tr>
					<td align="right" bgcolor="#32CD32" colspan="2" height="32">
						<img align="left" alt="Oracle
Corporation" height="30" src="https://s32.postimg.org/6riny3iid/oraclelogo.jpg" width="123" /><span style="font-size:18px;font-family: Arial, Helvetica,
align:center;sans-serif;color: #FFFFFF;"> <center><b>EM Handover Report</b></center></span></td>
				</tr>
			</tbody>
		</table>';
	

	ImportantLinks := '<html><head>

	<style>th, td, p  {
		font-size: 14px;
	}
	</style></head>
	<body>
	<body>
	<table border=1 cellpadding=10>
	<tr><th bgcolor="FFC000">Important Links</th></tr>
		<tr>
			<td><a href="https://confluence.oraclecorp.com/confluence/display/CDO/EOTD+-+GMP+Alert+SOPs">EOTD – SOPs</a></td>
		</tr>
		<tr>
			<td><a href="https://confluence.oraclecorp.com/confluence/display/CDO/Vendor+Contacts">Vendor Contacts</a></td>
		</tr>
		<tr>
		  <td><a href="  https://apex.oraclecorp.com/pls/apex/f?p=1648:142">Vendor Cases</a></td>
		</tr>
		<tr>
		  <td><a href="www.test.com">Outage Handbook</a></td>
		</tr>
		<tr>
		  <td><a href=" https://apex.oraclecorp.com/pls/apex/f?p=29232:1">On-Call Calendar</a></td>
		</tr>
		<tr>
		  <td><a href="https://confluence.oraclecorp.com/confluence/display/CDO/Outage+Process+Guideline">Generate Handover report</a></td>
		</tr>
	</table>
<h4><span style="color: #333399;">Shift timings &ndash; Shift A (06:00 AM IST to 02:30 PM IST) &ndash; Shift B (02:00 PM IST to 10:30 PM IST) &ndash; Shift C (10:00 PM IST to 06:30 AM IST)</span></h4>
	';


	OPEN cImportantInfo;
		
	ImportantInfo := '<html><head>
	<style>
	th, td, p  {
		font-size: 14px;
	}
	</style>
	</head>

	<body>
	<table border=1 cellpadding=10>
	<tr><th bgcolor="FFC000">Other Important Handover</th></tr>
	<tr>
		<th bgcolor="FFC000">Description</th>
		<th bgcolor="FFC000">Creation date (IST)</th>
		<th bgcolor="FFC000">Next due date (IST)</th>
		<th bgcolor="FFC000">Action taken</th>
		<th bgcolor="FFC000">Next action</th>
		</tr>';

	Loop

	FETCH cImportantInfo INTO ii;
	 EXIT WHEN cImportantInfo%NOTFOUND;
			ImportantInfo := ImportantInfo || '<tr><td>    ' || ii.DESCRIPTION || '   ';
			ImportantInfo := ImportantInfo || '</td><td>    ' || ii.CREATION_DATE || '   ';
			ImportantInfo := ImportantInfo || '</td><td>    ' || ii.NEXT_DUE_DATE || '   ';
			ImportantInfo := ImportantInfo || '</td><td>    ' || ii.ACTION_TAKEN || '   ';
			ImportantInfo := ImportantInfo || '</td><td>    ' || ii.next_action || '   ';
						  END LOOP; 
				  
	ImportantInfo := ImportantInfo ||' </td></tr></table></body></html> ';

	IF cImportantInfo%ROWCOUNT < 1

	THEN 

	ALERTS := '<p>Current Alerts<br><i>No Current Important info </i></p>';

	END IF;

	CLOSE cImportantInfo;
	-- END cImportantInfo

	OPEN cAlerts;
		
	ALERTS := '<html><head>
	<style>
	th, td, p  {
		font-size: 14px;
	}
	</style>
	</head>

	<body>
	<table border=1 cellpadding=10>
	<tr><th bgcolor="FFC000">Alerts Summary</th></tr>
	<tr>
		<th bgcolor="FFC000">Alert Type</th>
		<th bgcolor="FFC000">Total Alerts</th>
		<th bgcolor="FFC000">Ack in shift</th>
		<th bgcolor="FFC000">Closed</th>
		<th bgcolor="FFC000">Unacknowledged</th>
		</tr>';

	Loop

	FETCH cAlerts INTO aatt;
	 EXIT WHEN cAlerts%NOTFOUND;
			ALERTS := ALERTS || '<tr><td>    ' || aatt.ALERT_TYPE || '   ';
			ALERTS := ALERTS || '</td><td>    ' || aatt.TOTAL_ALERTS || '   ';
			ALERTS := ALERTS || '</td><td>    ' || aatt.ACK_IN_SHIFT || '   ';
			ALERTS := ALERTS || '</td><td>    ' || aatt.CLOSED || '   ';
			ALERTS := ALERTS || '</td><td>    ' || aatt.UNACK || '   ';
						  END LOOP; 
				  
	ALERTS := ALERTS ||' </td></tr></table></body></html> ';

	IF cAlerts%ROWCOUNT < 1

	THEN 

	ALERTS := '<p>Current Alerts<br><i>No Current Alerts</i></p>';

	END IF;

	CLOSE cAlerts;
	-- END cAlerts

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
				<td>'|| :P378_PREPARED_BY ||' </td>
			</tr>
			<tr>
				<td>Handover engineer:</td>
				<td>'|| :P378_NEXT_ENGINEER ||'</td>
			</tr>
			<tr>
				<td>Shift date:</td>
				<td>'|| :P378_CREATION_DATE ||'</td>
			</tr>
			<tr>
				<td>Shift:</td>
				<td>'|| :P378_SHIFT ||'</td>
			</tr>
			<tr>
				<td>Total SRs created:</td>
				<td>'|| :P378_TOTAL_SRS_CREATED ||'</td>
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

	<table border=1 cellpadding=10>
	<tr><th bgcolor="FFC000">Current Alerts</th></tr>
	<tr>
		<th bgcolor="FFC000">Report ID</th>
		<th bgcolor="FFC000">SR / EM Incident ID</th>
		<th bgcolor="FFC000">Description</th>
		<th bgcolor="FFC000">Device name</th>
		<th bgcolor="FFC000">Creation date(IST)</th>
		<th bgcolor="FFC000">Next Due Date(IST)</th>
		<th bgcolor="FFC000">Action taken</th>
		<th bgcolor="FFC000">Next Action</th>
	</tr>';

	Loop

	FETCH cAlertsAddress INTO AA;
	 EXIT WHEN cAlertsAddress%NOTFOUND;
	 AlertsAddress := AlertsAddress || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:276:::NO::P276_ALERT_ID:'||
aa.ALERT_ID||'>' || aa.ALERT_ID|| ''||  '';
			AlertsAddress := AlertsAddress || '</td><td>' || aa.EM_INCIDENT_ID || '   ';
			AlertsAddress := AlertsAddress || '</td><td>    ' || aa.DESCRIPTION || '   ';
			AlertsAddress := AlertsAddress || '</td><td>    ' || aa.DEVICE_NAME|| '   ';
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
	</head>
	<table border=1 cellpadding=10>
	<tr><th font color="red" bgcolor="FFC000">Missed Alerts</th></tr>
	<tr>
		<th bgcolor="FFC000"><font color="red">Report ID</font></th>
		<th bgcolor="FFC000"><font color="red">SR / EM Incident ID</th>
		<th bgcolor="FFC000"><font color="red">Description</font></th>
		<th bgcolor="FFC000"><font color="red">Device name</font></th>
		<th bgcolor="FFC000"><font color="red">Creation date(IST)</font></th>
		<th bgcolor="FFC000"><font color="red">Next Due Date(IST)</font></th>
		<th bgcolor="FFC000"><font color="red">Action taken</font></th>
		<th bgcolor="FFC000"><font color="red">Next Action</font></th>
	</tr>';

	Loop

	FETCH cMissingAlerts INTO MA;
	 EXIT WHEN cMissingAlerts%NOTFOUND;
		  MissingAlerts := MissingAlerts || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:276:::NO::P276_ALERT_ID:'||
ma.ALERT_ID||'>' || ma.ALERT_ID|| ''||  '';
			MissingAlerts := MissingAlerts || '</font></td><td><font color="red">' || ma.EM_INCIDENT_ID || '   ';
			MissingAlerts := MissingAlerts || '</font></td><td><font color="red">    ' || ma.DESCRIPTION || '   ';
			MissingAlerts := MissingAlerts || '</td><td><font color="red">    ' || ma.DEVICE_NAME || '   ';
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
	<body>
	<table border=1 cellpadding=10>
	<tr><th bgcolor="FFC000">Future Alerts</th></tr>
	<tr>
		<th bgcolor="FFC000">Report ID</th>
		<th bgcolor="FFC000">SR / EM Incident ID</th>
		<th bgcolor="FFC000">Description</th>
		<th bgcolor="FFC000">Device name</th>
		<th bgcolor="FFC000">Creation date(IST)</th>
		<th bgcolor="FFC000">Next Due Date(IST)</th>
		<th bgcolor="FFC000">Action taken</th>
		<th bgcolor="FFC000">Next Action</th>
	</tr>';


	Loop

	FETCH cFutureAlerts INTO FA;
	 EXIT WHEN cFutureAlerts%NOTFOUND;
	 FutureAlerts := FutureAlerts || '<tr><td>    <a href=https://apex.oraclecorp.com/pls/apex/f?p=1648:276:::NO::P276_ALERT_ID:'||
fa.ALERT_ID||'>' || fa.ALERT_ID|| ''||  '';
			FutureAlerts := FutureAlerts || '</td><td>   ' || FA.EM_INCIDENT_ID || '   ';
			FutureAlerts := FutureAlerts || '</td><td>    ' || FA.DESCRIPTION || '   ';
			FutureAlerts := FutureAlerts || '</td><td> ' || FA.DEVICE_NAME|| '   ';
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
	 l_body_html := '' || HeadingReport ||' <br> ' || Engineers ||' <br> '|| ALERTS ||' <br> '|| AlertsAddress || ' <br> ' || MissingAlerts || ' <br> ' || FutureAlerts ||' <br> '||  ImportantInfo || ' <br> ' || ImportantLinks || '' ;
	 



	/* SEND EMAIL FUNCTION */
		  apex_mail.send(
		 p_to        => 'cit_network_operations_ww_grp@oracle.com',
		 p_from      => 'cit_network_operations_ww_grp@oracle.com',
		 p_cc        => '',
		 p_body      => l_body,
		 p_body_html => l_body_html,
		 p_subj      => 'EM Handover | Shift '|| :P378_SHIFT ||' | '|| :P378_CREATION_DATE ||'',
		  p_bcc => '',
		  p_replyto => NULL
		 );
	/* END SEND EMAIL FUNCTION */



	END;