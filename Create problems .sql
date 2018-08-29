DECLARE

queueName VARCHAR(4000);
IncidentsQty NUMBER;
Category varchar(100);

Problem SD_PROBLEMS%rowtype;
 l_body_html CLOB;
 l_body CLOB; 
 

BEGIN
SELECT * INTO Problem 
FROM (SELECT * FROM sd_problems ORDER BY IDATE DESC) WHERE rownum = 1;


SELECT Q_NAME INTO queueName 
FROM SD_QUEUES
WHERE  Q_ID = problem.IMPACT;

SELECT CATEGORY INTO Category 
FROM SD_PROBLEMS_CATEGORIES WHERE ID = problem.CATEGORY_ID;





 
l_body := 'SERVICE DESK NOTIFICATIONS: NEW UPDATE HAS BEEN REPORTED INTO AN PROBLEM';
l_body_html := '<table style="border-collapse: collapse; width: 1290px; height: 176px;" class="MsoNormalTable cke_show_border" border="0" cellpadding="0" cellspacing="0">
<tbody>
<tr style="height: 112.5pt;">
<td style="padding: 0cm; padding-right:20px; width: 459.15pt; height: 100%; font-family: Calibri;" valign="top" width="612">
<h1><b style="">Problem description:<o:p></o:p></b><br>
</h1>
<p class="Instructions" style="margin-bottom: 0.0001pt; text-align: justify;">'||
Problem.description ||'&nbsp;</p>
<p class="Instructions" style="margin-bottom: 0.0001pt; text-align: justify;"></p>
<p class="Instructions" style="margin-bottom: 0.0001pt; text-align: justify;"></p>
</td>
<td style="border: medium none ; vertical-align: top; width: 148.5pt; padding-top: 0cm; padding-bottom: 0cm; white-space: nowrap;">
<pre><o:p></o:p>&nbsp; &nbsp;</pre>
<div style="text-align: rigth; font-family: Tahoma;"><big style="font-weight: bold;"><big><big><big>Rapid<span style="color: rgb(204, 0, 0);">SR</span></big></big></big></big></div>
<div style="text-align: rigth; height:60px;"><big style="font-family: Tahoma; color: rgb(204, 0, 0);"><big><big><big><span style="font-weight: bold;"><small>ServiceDesk</small></span></big></big></big></big>
</div>
</td>
</tr>
</tbody>
</table>
<table style="border: medium none ; border-collapse: collapse; background-color: rgb(204, 0, 0); width: 1190px;" class="GridTable3Accent1" border="1" cellpadding="0" cellspacing="0">
<tbody>
<tr style="height: 50px; vertical-align: middle;">
<td style="border-style: none none solid; border-color: -moz-use-text-color -moz-use-text-color rgb(200, 210, 189); border-width: medium medium 1pt; padding: 0cm; background: rgb(204, 0, 0) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; height: 49px; font-weight: bold; font-family: Tahoma; width: 72px;"><small>
</small>
<p class="MsoNormal" style="vertical-align:middle; text-align: center; line-height: normal; page-break-after: avoid; width: 88px;" align="center"><small><span style="color: rgb(124, 145, 99);"><big><span style="color: white; text-decoration: underline; font-family: Calibri;">Problem
ID</span></big><o:p></o:p></span></small></p>
<small></small></td>
<td style="border-style: none none solid; border-color: -moz-use-text-color -moz-use-text-color rgb(200, 210, 189); border-width: medium medium 1pt; padding: 0cm; background: rgb(204, 0, 0) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; color: white; height: 49px; font-weight: bold; font-family: Tahoma; width: 113px;"><small>
</small>
<p class="MsoNormal" style="vertical-align:middle; text-align: center; line-height: normal; page-break-after: avoid;" align="center"><small><u><big><span style="font-family: Calibri;">Tool</span></big><o:p></o:p></u></small></p>
<small></small></td>
<td style="border-style: none none solid; border-color: -moz-use-text-color -moz-use-text-color rgb(200, 210, 189); border-width: medium medium 1pt; padding: 0cm; background: rgb(204, 0, 0) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; color: white; width: 37px; height: 49px; font-weight: bold; font-family: Tahoma;"><small>
</small>
<p class="MsoNormal" style="vertical-align:middle; text-align: center; line-height: normal; page-break-after: avoid; width: 176px;" align="center"><small><u><big><span style="font-family: Calibri;">Service</span></big><o:p></o:p></u></small></p>
<small></small></td>
<td style="border-style: none none solid; border-color: -moz-use-text-color -moz-use-text-color rgb(200, 210, 189); border-width: medium medium 1pt; padding: 0cm; background-image: none; background-repeat: repeat; background-attachment: scroll; background-position: 0% 50%; color: white; height: 49px; font-weight: bold; font-family: Tahoma; width: 220px;"><small>
</small>
<p class="MsoNormal" style="vertical-align:middle; text-align: center; line-height: normal; page-break-after: avoid; width: 222px;" align="center"><small><u><big><span style="font-family: Calibri;">Protocol</span></big><o:p></o:p></u></small></p>
<small></small></td>
<td style="border-style: none none solid; border-color: -moz-use-text-color -moz-use-text-color rgb(200, 210, 189); border-width: medium medium 1pt; padding: 0cm; background-image: none; background-repeat: repeat; background-attachment: scroll; background-position: 0% 50%; color: white; height: 49px; font-weight: bold; font-family: Tahoma; width: 116px;"><small>
</small>
<p class="MsoNormal" style="vertical-align:middle; text-align: center; line-height: normal; page-break-after: avoid; margin-left: 5px; width: 128px;" align="center"><small><u><big><span style="font-family: Calibri;">Status</span></big><o:p></o:p></u></small></p>
<small></small></td>
<td style="border-style: none none solid; border-color: -moz-use-text-color -moz-use-text-color rgb(200, 210, 189); border-width: medium medium 1pt; padding: 0cm; background-image: none; background-repeat: repeat; background-attachment: scroll; background-position: 0% 50%; color: white; height: 49px; font-weight: bold; font-family: Tahoma; width: 79px;"><small>
</small>
<p class="MsoNormal" style="vertical-align:middle; text-align: center; line-height: normal; page-break-after: avoid; margin-left: 5px; width: 75px;" align="center"><small><u><big><span style="font-family: Calibri;">Priority</span></big><o:p></o:p></u></small></p>
<small></small></td>
<td style="border-style: none none solid; border-color: -moz-use-text-color -moz-use-text-color rgb(200, 210, 189); border-width: medium medium 1pt; padding: 0cm; background-image: none; background-repeat: repeat; background-attachment: scroll; background-position: 0% 50%; color: white; height: 49px; width: 227px; font-weight: bold; font-family: Tahoma;"><small>
</small>
</small>
<p class="MsoNormal" style="vertical-align:middle; text-align: center; line-height: normal; page-break-after: avoid; width: 196px;" align="center"><small><u><big><span style="font-family: Calibri;">Creation Date<br>(CLT Santiago)</span></big><o:p></o:p></u></small></p>
<small></small></td>
<td style="border-style: none none solid; border-color: -moz-use-text-color -moz-use-text-color rgb(200, 210, 189); border-width: medium medium 1pt; padding: 0cm; background-image: none; background-repeat: repeat; background-attachment: scroll; background-position: 0% 50%; color: white; height: 49px; width: 227px; font-weight: bold; font-family: Tahoma;"><small>
</small>
<p class="MsoNormal" style="vertical-align:middle; text-align: center; line-height: normal; page-break-after: avoid; width: 196px;" align="center"><small><u><big><span style="font-family: Calibri;">ETA<br>(CLT Santiago)</span></big><o:p></o:p></u></small></p>
<small></small></td>
</tr>
<tr style="height: 23.75pt;">
<td style="border-style: none solid solid none; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189) -moz-use-text-color; border-width: medium 1pt 1pt medium; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; text-align: center; height: 46px; width: 113px; font-family: Calibri;">
<p class="MsoNormal" style="margin-bottom: 0.0001pt; line-height: normal; page-break-after: avoid; width: 88px;"><a href="https://apex.oraclecorp.com/pls/apex/f?p=11922:10:::NO::P10_ID:'||
Problem.ID ||'"><o:p>&nbsp;'||
Problem.ID ||'</o:p></a></p>
</td>
<td style="border-style: none solid solid none; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189) -moz-use-text-color; border-width: medium 1pt 1pt medium; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; text-align: center; height: 46px; width: 113px; font-family: Calibri;">
<p class="MsoNormal" style="margin-bottom: 0.0001pt; line-height: normal; page-break-after: avoid; width: 92px;"><o:p>&nbsp;'||
Problem.tool ||'</o:p></p>
</td>
<td style="border-style: none solid solid none; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189) -moz-use-text-color; border-width: medium 1pt 1pt medium; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; text-align: center; width: 37px; height: 46px; font-family: Calibri;">
<p class="MsoNormal" style="margin-bottom: 0.0001pt; line-height: normal; page-break-after: avoid; width: 176px;"><o:p>&nbsp;'||
category ||'</o:p></p>
</td>
<td style="border-style: none solid solid none; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189) -moz-use-text-color; border-width: medium 1pt 1pt medium; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; text-align: center; height: 46px; font-family: Calibri; width: 220px;">
<p class="MsoNormal" style="margin-bottom: 0.0001pt; line-height: normal; page-break-after: avoid; width: 222px;"><o:p>&nbsp;'||
Problem.protocol_used ||'</o:p></p>
</td>
<td style="border-style: none solid solid none; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189) -moz-use-text-color; border-width: medium 1pt 1pt medium; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; text-align: center; height: 46px; font-family: Calibri; width: 116px;">
<p class="MsoNormal" style="margin-bottom: 0.0001pt; line-height: normal; page-break-after: avoid; margin-left: 4px; width: 128px;"><o:p>&nbsp;'||
Problem.status ||'</o:p></p>
</td>
<td style="border-style: none solid solid none; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189) -moz-use-text-color; border-width: medium 1pt 1pt medium; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; text-align: center; height: 46px; width: 79px; font-family: Calibri;">
<p class="MsoNormal" style="margin-bottom: 0.0001pt; line-height: normal; page-break-after: avoid; margin-left: 5px; width: 75px;"><o:p style="font-family: Calibri;">'
|| problem.priority||'</o:p></p>
</td>
<td style="border-style: none solid solid none; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189) -moz-use-text-color; border-width: medium 1pt 1pt medium; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; text-align: center; height: 46px; width: 227px; font-family: Calibri;">
<p class="MsoNormal" style="margin-bottom: 0.0001pt; line-height: normal; page-break-after: avoid; width: 196px;"><o:p>'||
to_char(Problem.idate,'dd/mon/yyyy hh24:mi') ||'</o:p></p>
</td>
<td style="border-style: none solid solid none; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189) -moz-use-text-color; border-width: medium 1pt 1pt medium; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; text-align: center; height: 46px; width: 227px; font-family: Calibri;">
<p class="MsoNormal" style="margin-bottom: 0.0001pt; line-height: normal; page-break-after: avoid; width: 196px;"><o:p>'||
to_char(Problem.SOLUTION_DATE,'dd/mon/yyyy hh24:mi') ||'</o:p></p>
</td>
</tr>
</tbody>
</table>


<table style="border: medium none ; border-collapse: collapse; background-color: rgb(204, 0, 0); width: 1190px; height: 20px;" class="GridTable3Accent1" border="1" cellpadding="0" cellspacing="0">
<tbody>
<tr style="height: 23.75pt;">
<td style="border-style: none solid solid; vertical-align:middle; border-color: -moz-use-text-color rgb(200, 210, 189) rgb(200, 210, 189); border-width: medium 1pt 1pt; padding: 0cm; background: rgb(236, 240, 233) none repeat scroll 0% 50%; -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial; width: 63.6pt; height: 23.75pt; font-family: Calibri;">
<b>Mitigation: </b>'||
problem.mitigation ||'&nbsp;</td>
</tr>
</tbody>
</table>
<br>


</span><span style="font-weight: bold;"></span><span style="font-weight: bold;">24/7 Rapid<span style="color: rgb(204, 0, 0);">SR</span></span></big></big></span></strong></big><span style="font-family: &quot;Arial Narrow&quot;,&quot;sans-serif&quot;;" lang="ES-CL">
</span><span style="" lang="ES-CL"><a href="xmpp:rapidsr_service_desk_scl@conference.oracle.com?join"><span style="font-family: &quot;Arial Narrow&quot;,&quot;sans-serif&quot;;">Servicedesk
Chatroom</span></a>
<o:p></o:p></span>';

APEX_MAIL.send(
p_to =>  'rapidsr_sd_problem_mngt_grp@ORACLE.COM',
p_from => :app_user,
p_body => l_body,

p_body_html => l_body_html,

p_SUBJ => 'A New ' || PROBLEM.TOOL || ' problem (ID# '|| PROBLEM.ID ||') has been reported. Summary: '|| PROBLEM.summary ||'',
p_cc => '',
p_bcc => NULL ,
p_replyto => NULL

);


END;