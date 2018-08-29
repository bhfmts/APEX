DECLARE
    v_recipient VARCHAR2(4000);
    v_sendto VARCHAR2(4000);
    v_dtgstart VARCHAR2(200);
    l_body      CLOB;
    l_body_html CLOB;
    v_cc VARCHAR2(4000);
    v_location VARCHAR2 (4000);
    v_lob VARCHAR2 (4000);
    v_ecalc VARCHAR2(100); /* calculation for end time */
	v_ehours VARCHAR2(100); /* hours for end time */
    v_emins VARCHAR2(100); /* minutes for end time */
    v_etime VARCHAR2(100); /* time holder for end time */
    v_ehrs VARCHAR2(100); /* hrs holder for end time */
	v_rcalc VARCHAR2(100); /* calculation for restore time */
	v_rhours VARCHAR2(100); /* hours for restore time */
    v_rmins VARCHAR2(100); /* minutes for restore time */
    v_rtime VARCHAR2(100); /* time holder for restore time */
    v_rhrs VARCHAR2(100); /* hrs holder for restore time */
    v_newtitle VARCHAR2(100);
    v_incident_tracking VARCHAR2(400);
    v_restore_actions VARCHAR2(4000);
    v_followup_actions VARCHAR2(4000);
    v_services VARCHAR2(4000);
    v_mos_link_text VARCHAR2(100);
	v_locother VARCHAR(4000);
    v_status VARCHAR2(4000);
    v_incidentid VARCHAR2(4000);
    v_date DATE;
	v_lob1 VARCHAR2(4000);
    v_newvar VARCHAR2(4000);

BEGIN
/* FOR DIFFERENCE BETWEEN START AND END */
if :P41_DTGEND IS NOT NULL THEN
select (DTGEND - DTGSTART )*24*60 into v_ecalc from iss_incident_details where INCIDENTID = :P41_INCIDENTID;

v_ehours := TO_CHAR(v_ecalc/60, 999);
v_emins := TO_CHAR(MOD(v_ecalc,60), 999);
v_ehrs :=  TO_CHAR((v_ecalc - v_emins)/60, 999);

if v_ecalc < 60 then
v_etime := v_emins||' Mins.';
else
v_etime := v_ehrs||' Hrs. '||v_emins||' Mins.';
end if;
end if;
/* END FOR DIFFERENCE BETWEEN START AND END */

/* SETUP FOR DIFFERENCE BETWEEN RESTORE AND END */
if :P41_DTGRESTORE IS NOT NULL THEN
select (DTGRESTORE - DTGSTART)*24*60 into v_rcalc from iss_incident_details where INCIDENTID = :P41_INCIDENTID;

v_rhours := TO_CHAR(v_rcalc/60, 999);
v_rmins := TO_CHAR(MOD(v_rcalc,60), 999);
v_rhrs :=  TO_CHAR((v_rcalc - v_rmins)/60, 999);

if v_rcalc < 60 then
v_rtime := v_rmins||' Mins.';
else
v_rtime := v_rhrs||' Hrs. '||v_rmins||' Mins.';
end if;
end if;
/* END SETUP FOR DIFFERENCE BETWEEN RESTORE AND END */


/* Email notification setup */
if :P41_EMAIL_NOTIFY is NOT NULL then
    v_recipient := :P41_EMAIL_NOTIFY;
end if;
if :P41_EMAIL_STAKEHOLDER is NOT NULL then
    v_recipient := v_recipient || ',' || :P41_EMAIL_STAKEHOLDER;
end if;
if :P41_EMAIL_LOB is NOT NULL then
    v_recipient := v_recipient || ',' || :P41_EMAIL_LOB;
end if;

if v_recipient IS NOT NULL then
    v_sendto := replace(v_recipient, ' ', ',');
    v_sendto := replace(v_recipient, ':', ',');
else
    v_sendto := :APP_USER;
end if;

v_newvar := LTRIM(v_sendto, ',');

if :P41_ADDITIONALEMAIL is NOT NULL then
    v_cc := replace(:P41_ADDITIONALEMAIL, ';', ',');
end if;
/* END Email notification setup */

/* LOB Selection Setup */
if :P41_IMPCT_LOB is NOT NULL then
   v_lob := :P41_IMPCT_LOB;
end if;

if :P41_OTHER_LOB is NOT NULL then
   if v_lob is NOT NULL then
   v_lob := v_lob || '<br />' || :P41_OTHER_LOB;
   else
   v_lob := :P41_OTHER_LOB;
   end if;
end if;  



if v_lob is NOT NULL then
   v_lob := replace(v_lob, ':', '<br />');
   v_lob := replace(v_lob, ', ', '<br />');
   v_lob := replace(v_lob, ',', '<br />');
end if;


/* END LOB Selection Setup */


/*Check Services for Other*/ 
if :P41_OTHER_SERVICES is NOT NULL then
   v_services := :P41_OTHER_SERVICES;
 else
   v_services := :P41_INCIDENT_SERVICES;
end if;
/*end of Check Services */


/*Check Location for Other*/ 
if :P41_OTHER_LOCATION is NOT NULL then
   v_locother := :P41_OTHER_LOCATION;
 else
   v_locother := :P41_IMPCT_LOCATION;
end if;
/*end of Check Location */


/*Set up Notification Type*/ 
/* Set Notice to NEW: to start with*/ 
:P41_NOTIF_STATUS := 'NEW: ';

/* If Status Update is not empty, this is an update */
if :P41_UPDATE_STATUS IS NOT NULL then
:P41_NOTIF_STATUS := 'UPDATE: ';
end if;

/* If the End Date/time is entered in, this is closed */
if :P41_DTGEND IS NOT NULL then
:P41_NOTIF_STATUS := 'CLOSED: ';
end if;
/* End of Notification type */


/* Set up the acronym for the subject line, based on selected location */
if :P41_OTHER_LOCATION is NOT NULL then
 v_location := :P41_OTHER_LOCATION;
 else
	select APP_DISPLAY_VAL INTO v_location from iss_APPLICATION_LOV where APP_RETURN_VAL=:P41_IMPCT_LOCATION;
end if;

/* End of subject line location set up */


/* LINE FOR NON HTML BROWSERS */
l_body := 'Please use an HTML Enabled Browser to view this Email'||utl_tcp.crlf;
/* END LINE FOR NON HTML BROWSERS */



/* HTML EMAIL SETUP - HTML HEAD BODY */
l_body_html := '<html>';
l_body_html := l_body_html ||'<head>'||utl_tcp.crlf;
l_body_html := l_body_html ||'</head>'||utl_tcp.crlf;
l_body_html := l_body_html ||'<body>'||utl_tcp.crlf;

/* BEGIN OUTER TABLE */
l_body_html := l_body_html ||'<table width="615" border="0" align="center" cellpadding="0" cellspacing="0" RULES=NONE FRAME=BOX style="cellpadding:0 cellspacing:0">'||utl_tcp.crlf;

/* ORACLE LOGO */
l_body_html := l_body_html ||'<tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'<td height="32" colspan="2" bgcolor="#FF0000"><img src="http://www.steadmanusa.com/orared.gif" alt="Oracle Corporation" width="123" height="30" /></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'</tr>'||utl_tcp.crlf;
/* END ORACLE LOGO */

/* BLANK ROW */
l_body_html := l_body_html ||'<tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'<td colspan="2">&nbsp;</td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'</tr>'||utl_tcp.crlf;
/* END BLANK ROW */

/* SETUP TITLE AREA */
l_body_html := l_body_html ||'<tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'<td colspan="2"><div align="center"><b><span style="font-size:24px;font-family: Arial, Helvetica, sans-serif;color: #000000;font-style: italic;">';


if :P41_DTGEND IS NOT NULL then
l_body_html := l_body_html ||REPLACE(:P41_NOTIF_STATUS,':','<br/>');
elsif :P41_UPDATE_STATUS is NOT NULL then
l_body_html := l_body_html ||REPLACE(:P41_NOTIF_STATUS,':','<br/>');
ELSE 
l_body_html := l_body_html ||REPLACE(:P41_NOTIF_STATUS,':','<br/>');
end if;

l_body_html := l_body_html ||'CIT COE Incident Management Notification<br/>';
l_body_html := l_body_html || v_locother ||' - '|| v_services;
l_body_html := l_body_html ||'</span></div></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'</tr>'||utl_tcp.crlf;
/* END SETUP TITLE AREA */

/* BLANK LINE */
l_body_html := l_body_html ||'<tr><td height="25" colspan="2"></td></tr>'||utl_tcp.crlf;
/* END BLANK LINE */

/* BEGIN ROW WITH INTERNAL TABLE FOR DETAILS */
l_body_html := l_body_html ||'<tr><td colspan="2"><div align="center"><table width="580" border="1" align="center" cellpadding="2" cellspacing="1"><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">'||utl_tcp.crlf;

/* Begin Start time */
l_body_html := l_body_html ||'<tr><td width="25%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Incident Start Time:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_DTGSTART,CHR(13)||CHR(10),'<br/>');
l_body_html := l_body_html ||REPLACE (' PT'||CHR(10),'<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
/* End start time */

/* Begin Restore time */
if :P41_DTGRESTORE is NOT NULL THEN
	if :P41_DTGEND IS NULL THEN
		l_body_html := l_body_html ||'<tr><td width="25%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Service Restoration Time:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
		l_body_html := l_body_html || :P41_DTGRESTORE;
		l_body_html := l_body_html || ' PT (' ||  v_rtime || ')';
		l_body_html := l_body_html ||' </span></td></tr>'||utl_tcp.crlf;
		l_body_html := l_body_html ||'<tr><td width="25%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Incident End Time:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
        l_body_html := l_body_html || 'TBD';
		l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
	ELSE 	
		l_body_html := l_body_html ||'<tr><td width="25%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Service Restoration Time:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
		l_body_html := l_body_html || :P41_DTGRESTORE;
		l_body_html := l_body_html || ' PT (' ||  v_rtime || ')';
		l_body_html := l_body_html ||' </span></td></tr>'||utl_tcp.crlf;
	END IF;
END IF;
/* End Restore time */

/* Begin End time */
if :P41_DTGEND IS NOT NULL then
l_body_html := l_body_html ||'<tr><td width="25%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Incident End Time:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||:P41_DTGEND || ' PT (' ||  v_etime || ')';
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End End time */

/* Begin Description */
l_body_html := l_body_html ||'<tr><td width="38%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Incident Description:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_INCIDENT_DESCRIPTION,CHR(13)||CHR(10),'<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
/* End Description */

/* Begin Business Impact */
if :P41_BUSINESS_IMPACT is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="20%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Business Impact:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_BUSINESS_IMPACT,':','<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Business Impact */

/* Begin Update Status */
if :P41_UPDATE_STATUS is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="25%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Status Update:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;color:#ff0000">';
l_body_html := l_body_html ||REPLACE(:P41_UPDATE_STATUS,CHR(13)||CHR(10),'<br/>');
l_body_html := l_body_html || '<br/><a href="https://apex.oraclecorp.com/pls/apex/f?p=CITNETSEC:IRC_INCIDENTVIEW:::NO::P42_INCIDENTID:'||:P41_INCIDENTID||'">View all Status Updates</a>';
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Status Update */

/* Begin Impacted Services */
l_body_html := l_body_html ||'<tr><td width="25%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Impacted Service(s):</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html || v_services;
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
/* End Impacted Services */

/* Begin Device Name */
l_body_html := l_body_html ||'<tr><td width="25%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Impacted Device(s):</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html || :P41_DEVICE_NAME;
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
/* End Device Name */

/* Zone Tracking */
if :P41_INCIDENT_ZONE is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="20%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Impacted Zone(s):</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_INCIDENT_ZONE,':','<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Zone */

/*
if :P41_IMPCT_LOB is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="20%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Impacted Customer(s):</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_IMPCT_LOB,':','<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Impact LOB */

/* Begin Impact LOB*/
if v_lob is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="20%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Impacted Customer(s):</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html || v_lob;
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Impact LOB */


/* HOLD SPOT FOR ONDEMAND BUSINESS IMPACT */

/* Begin Impacted Instances */
if :P41_IMPCT_PROD > 0 then
l_body_html := l_body_html ||'<tr><td width="25%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Impacted Instance(s):</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||'PROD: ';
l_body_html := l_body_html ||REPLACE(:P41_IMPCT_PROD,CHR(13)||CHR(10),'<br/>');
if :P41_IMPCT_NONPROD > 0 then
l_body_html := l_body_html ||'<br/>NON-PROD: ';
l_body_html := l_body_html ||REPLACE(:P41_IMPCT_NONPROD,CHR(13)||CHR(10),'<br/>');
end if;
if :P41_IMPCT_DR > 0 then
l_body_html := l_body_html ||'<br/>DR: ';
l_body_html := l_body_html ||REPLACE(:P41_IMPCT_DR,CHR(13)||CHR(10),'<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
ELSIF :P41_IMPCT_NONPROD > 0 then
l_body_html := l_body_html ||'<tr><td width="25%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Impacted Instance(s):</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||'NON-PROD: ';
l_body_html := l_body_html ||REPLACE(:P41_IMPCT_NONPROD,CHR(13)||CHR(10),'<br/>');
if :P41_IMPCT_DR > 0 then
l_body_html := l_body_html ||'<br/>DR: ';
l_body_html := l_body_html ||REPLACE(:P41_IMPCT_DR,CHR(13)||CHR(10),'<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
ELSIF :P41_IMPCT_DR > 0 then
l_body_html := l_body_html ||'<tr><td width="25%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Impacted Instance(s):</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||'DR: ';
l_body_html := l_body_html ||REPLACE(:P41_IMPCT_DR,CHR(13)||CHR(10),'<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Impacted Instances */

/* Begin Incident Level */
l_body_html := l_body_html ||'<tr><td width="25%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Incident Level:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_INCIDENT_LEVEL,CHR(13)||CHR(10),'<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
/* End Incident level */

/* Begin Location */
l_body_html := l_body_html ||'<tr><td width="25%"  align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Location:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html || v_locother;
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
/* End Location */

/*Begin Region */
if :P41_INCIDENT_REGION is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="25%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Region:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_INCIDENT_REGION,':','<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Region */

/*Teleservices Tracking */
if :P41_TELESERVICESTIX is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="20%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Teleservices:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_TELESERVICESTIX,':','<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Tracking */

/*MyHelp Tracking */
if :P41_CRMODTIX is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="20%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">MyHelp:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_CRMODTIX,':','<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Tracking */

/*Master Incident Tracking */
if :P41_MASTER_INCIDENT is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="20%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">Master Incident:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_MASTER_INCIDENT,':','<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/* End Tracking */

/* SR Number */
if :P41_MOS_TIX is NOT NULL then
l_body_html := l_body_html ||'<tr><td width="20%" align="right"><b><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">MOS SR:</span></b></td><td><span style="font-size:16px;font-family: Arial, Helvetica, sans-serif;">';
l_body_html := l_body_html ||REPLACE(:P41_MOS_TIX,':','<br/>');
l_body_html := l_body_html ||'</span></td></tr>'||utl_tcp.crlf;
end if;
/*End Sr number */

l_body_html := l_body_html ||'<br></span></table></div></td></tr>'||utl_tcp.crlf;
/* End Table */
/* END OF INTERNAL TABLE ROW */

/* BLANK ROW */
l_body_html := l_body_html ||'<tr><td height="25" colspan="2"></td></tr> '||utl_tcp.crlf;
/* END BLANK ROW */

/* HARD RETURN LINE */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td colspan="2"><hr size="2" width="80%" align="center" /></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END HARD RETURN LINE */

/* LINK TO VIEW INCIDENT */
l_body_html := l_body_html ||'<tr><td colspan="2"><p align="left"><span style ="font-family: Arial, Helvetica, sans-serif; font-size: 14px; padding-left:10%; padding-right:10%;">Incident details can be found <a href="https://apex.oraclecorp.com/pls/apex/f?p=1648:42:::NO::P42_INCIDENTID:'||:P41_INCIDENTID||'">Here</a><br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'<span style ="font-family: Arial, Helvetica, sans-serif; font-size: 12px; padding-left:10%; padding-right:10%; color:red;"><b>NOTE:</b> You must be logged in to the Oracle Network to view the full incident.</span></span></p></td></tr>'||utl_tcp.crlf;
/* END LINK TO VIEW INCIDENT */

/* BLANK ROW */
l_body_html := l_body_html ||'<tr><td colspan="2"></td></tr>'||utl_tcp.crlf;
/* END BLANK ROW */

/* BLANK ROW */
l_body_html := l_body_html ||'<tr><td height="25" colspan="2"></td></tr>'||utl_tcp.crlf;
/* END BLANK ROW */

/* SUPPORT LINE */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td colspan="2"><span style="font-size:14px;font-family: Arial, Helvetica, sans-serif;"><b>Support and Resources</b><br></span></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END SUPPORT LINE */

/* EMAIL CONTACT LINK */
if :P41_TEAM <> 'MIM' then
l_body_html := l_body_html ||'<tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'   <td colspan="2"><span style="font-size:14px;font-family: Arial, Helvetica, sans-serif;">For more information or feedback, please contact the team at '||utl_tcp.crlf;
l_body_html := l_body_html ||'<a href="mailto: citnetsec-ops_ww_grp@oracle.com"> citnetsec-ops_ww_grp@oracle.com</a><br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'        <br>'||utl_tcp.crlf;
l_body_html := l_body_html ||'        Thank You,<br>'||utl_tcp.crlf;
l_body_html := l_body_html ||'        CIT COE Management Team'||utl_tcp.crlf;
l_body_html := l_body_html ||'   </span></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'</tr>'||utl_tcp.crlf;
ELSE
l_body_html := l_body_html ||'<tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'   <td colspan="2"><span style="font-size:14px;font-family: Arial, Helvetica, sans-serif;">For more information or feedback, please contact the team at <br> '||utl_tcp.crlf;
l_body_html := l_body_html ||'<a href="mailto:MIM-Team_WW@oracle.com">MIM-Team_WW@oracle.com</a><br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'        <br>'||utl_tcp.crlf;
l_body_html := l_body_html ||'        Thank You,<br>'||utl_tcp.crlf;
l_body_html := l_body_html ||'        GIT Incident Management'||utl_tcp.crlf;
l_body_html := l_body_html ||'   </span></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'</tr>'||utl_tcp.crlf;
end if;

/* END EMAIL CONTACT LINK */

/* HARD RETURN */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td colspan="2"><hr size="1" width="80%" align="center" /></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END HARD RETURN */

/* CONFIDENTIAL STATEMENT */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td colspan="2"><div align="center"><span style="font-size: 10px;font-family: Arial, Helvetica, sans-serif;">CONFIDENTIAL - - SUN AND ORACLE INTERNAL<br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'      The information contained in this email communication should not be shared or  communicated <br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'    outside of Sun and Oracle. Local entity combinations worldwide will proceed in  accordance with local laws.</span><br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'    </div></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END CONFIDENTIAL STATEMENT */

/* HARD RETURN */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td colspan="2"><hr size="2" width="100%" align="left" /></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END HARD RETURN */

/* BLANK ROW */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td colspan="2">&nbsp;</td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END BLANK ROW */

/* SOFTWARE HARDWARE COMPLETE LOGO */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td colspan="2"><div class="imagefile"><img src="http://cerebus.us.oracle.com/images/HardwareandSoftware.gif" alt="SOFTWARE HARDWARE COMPLETE" width="140" height="42" border="0" /></div></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END SOFTWARE HARDWARE COMPLETE LOGO */

/* BLANK ROW */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td colspan="2">&nbsp;</td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END BLANK ROW */

/* HARD RETURN LINE */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td height="2" colspan="2" valign="bottom"><hr size="2" width="100%" align="left" /></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END HARD RETURN LINE */

/* COPYRIGHT INFORMATION AND LINKS */
l_body_html := l_body_html ||'  <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td width="276" bordercolor="#FF0000"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 9px; padding-top:0px; margin-top:0px;">Copyright 2010, Oracle Corporation <br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'and/or its affiliates. All rights reserved</span></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td width="318"><div align="right"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 9px; color: #FF0000;"><a href="http://www.myaddress.com/corporate/contact/" target="_blank">Contact Us</a> | <a href="http://www.myorg.com/html/copyright.html" target="_blank">Legal Notices and Terms of Use</a> | <a href="http://www.myorg.com/html/privacy.html" target="_blank">Privacy Statement</a></span></div></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
/* END COPYRIGHT INFORMATION AND LINKS */

/* END TABLE */
l_body_html := l_body_html ||'</table>'||utl_tcp.crlf;

/* ADDRESS TABLE */
l_body_html := l_body_html ||'<table width="615" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#000000">'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'<td height="3" colspan="2"><hr size="2" width="100%" align="center" /></td></tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'<tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'    <td height="21" colspan="2" valign="top"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 9px; padding-top:0px; margin-top:0px;">Oracle Corporation - Worldwide Headquarters<br />'||utl_tcp.crlf;
l_body_html := l_body_html ||'500 Oracle Parkway, Redwood Shores, CA 94065 U.S.A.</span></td>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'  </tr>'||utl_tcp.crlf;
l_body_html := l_body_html ||'</table>'||utl_tcp.crlf;
/* END ADDRESS TABLE */

/* EMAIL SENT BY LINE */
l_body_html := l_body_html ||utl_tcp.crlf;
l_body_html := l_body_html ||'<br><br><br>';
l_body_html := l_body_html ||utl_tcp.crlf;
l_body_html := l_body_html ||'<span style="font-family: Arial, Helvetica, sans-serif; font-size: 9px; color:black;"> Email sent ';
l_body_html := l_body_html ||TO_CHAR(SYSDATE-2/24, 'DD-MON-RRRR HH24:MI');
l_body_html := l_body_html ||' PT.  Email sent by: ';
l_body_html := l_body_html ||:APP_USER;
l_body_html := l_body_html ||'</span>' || utl_tcp.crlf;
/* END EMAIL SENT BY LINE */

/* END HTML AND BODY */
l_body_html := l_body_html ||'</body>'||utl_tcp.crlf;
l_body_html := l_body_html ||'</html>'||utl_tcp.crlf;

/* SEND EMAIL FUNCTION */
      apex_mail.send(
     p_to        => v_sendto,
     p_from      => :GITSVCOPSEMAIL,
     p_cc        => v_cc,
     p_body      => l_body,
     p_body_html => l_body_html,
     p_subj      => :P41_NOTIF_STATUS ||'Incident Management Notification: '|| v_location || ' '|| v_services,
p_bcc => NULL ,
p_replyto => NULL
	 );
EXCEPTION
   WHEN NO_DATA_FOUND THEN
--

/* END SEND EMAIL FUNCTION */

/* set up incident title for use on RCCA page */
select :P41_NOTIF_STATUS || ' ' ||:P41_IMPCT_LOCATION ||' '|| :P41_INCIDENT_SERVICES into v_newtitle from iss_incident_details where incidentid=:P41_INCIDENTID;
update iss_incident_details set incident_title = v_newtitle where incidentid=:P41_INCIDENTID;


/* INSERT SYSTEM UPATES INTO ISS_INC_STAT_UPDATE TO QUERY LATER ON THE VIEW PAGE */
if :P41_UPDATE_STATUS is NOT NULL then
  -- v_date := to_char(SYSDATE, 'DD-MON-YYYY HH24:MI');
  v_date := SYSDATE;
   v_incidentid := :P41_INCIDENTID;
   v_status := :P41_UPDATE_STATUS;
INSERT INTO ISS_INC_STAT_UPDATE (INCIDENTID, DATEADDED, STATUSUPDATE, UPDATED_BY) VALUES (v_incidentid, v_date, v_status, :APP_USER);
end if;

/* END ISS_INC_STAT_UPDATE INSERT STATEMENT */
/* we are getting there*/

END;