
/***************************************************************/
/* START: Configuration                                        */
/***************************************************************/
declare
	@formatTableHead varchar(max), --table head format
	@formatForeignKey varchar(max), --foreign key format
	@formatColumn varchar(max), --print format for column
	@docTitle varchar(max), --documentation title
	@docStartHeading1 int, --starting number for heading level 1
	@docStartHeading2 int,
	@docTableOpen varchar(max), --opening table documentation
	@docTableClose varchar(max), --closing table documentation
	@heading1 varchar(max), @heading2 varchar(max), @heading3 varchar(max), @heading4 varchar(max), @headingDatabase varchar(max),
	@docClosing varchar(max), @styles varchar(max);
set @docTableOpen = '<table class="MsoNormalTable" border="1" cellspacing="0" cellpadding="0" width="601" class="doc-table">
	<tr style="mso-yfti-irow:0;mso-yfti-firstrow:yes">
		<td width="29" class="doc-table-row header" style="width:21.75pt;background:black;color:white;font-weight:bold;vertical-align:middle;"><p class="MsoNormal" align="center" style="text-align:center;">No</p></td>
		<td width="143" class="doc-table-row header next" style="width:107.5pt;background:black;color:white;font-weight:bold;vertical-align:middle;"><p class="MsoNormal" style="text-align:center;">Field</p></td>
		<td width="104" class="doc-table-row header next" style="width:77.8pt;background:black;color:white;font-weight:bold;vertical-align:middle;"><p class="MsoNormal" style="text-align:center;">Data Type</p></td>
		<td width="85" class="doc-table-row header next" style="width:63.7pt;background:black;color:white;font-weight:bold;vertical-align:middle;"><p class="MsoNormal" style="text-align:center;">Nullable</p></td>
		<td width="240" class="doc-table-row header next" style="width:180.0pt;background:black;color:white;font-weight:bold;vertical-align:middle;"><p class="MsoNormal" style="text-align:center;">Description</p></td>
	</tr>';
set @docTableClose = '</table>';
set @docTitle = DB_NAME() + ' Database Documentation';
set @docStartHeading1 = 1;
set @docStartHeading2 = 2; --normally, you don't need to change this
set @docClosing = '
</div>
</body>
</html>
';
set @formatTableHead = '
<h3>
	<a name="Table_!TABLE_ID!">
		<span class="text-title">!DOC_START_HEADING1!.!DOC_START_HEADING2!.!TABLE_NO!<span style="font-size:7.0pt">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span>
		<span class="text-title">Table </span>
	</a>
	<span class="text-title">!TABLE_NAME!</span>
</h3>
<p class=MsoNormal>!DESCRIPTION!</p>
';
set @formatColumn = 
'	<tr style="mso-yfti-irow:!COLUMN_NO!">
		<td class="doc-table-row" style="vertical-align:top;"><p class="MsoNormal number" style="text-align:right;">!COLUMN_NO!.</p></td>
		<td class="doc-table-row next data"" style="vertical-align:top;"><p class="MsoNormal">!COLUMN_NAME!</p></td>
		<td class="doc-table-row next data"" style="vertical-align:top;"><p class="MsoNormal">!COLUMN_TYPE!</p></td>
		<td class="doc-table-row next data"" style="vertical-align:top;"><p class="MsoNormal">!COLUMN_ISNULLABLE!</p></td>
		<td class="doc-table-row next data"" style="vertical-align:top;"><p class="MsoNormal">!COLUMN_DESCRIPTION!</p></td>
	</tr>';
set @formatForeignKey = 'Foreign key to <a href="#Table_!TABLE_ID!" title="Click to see detail" style="color:black;text-decoration:none;font-size:10pt;font-family:''Arial Narrow'',''sans-serif''">!TABLE_NAME!</a> field !COLUMN_NAME!. ';
set @styles = '
<style type="text/css">
.text-title{font-variant:normal !important;/*text-transform:uppercase;*/}
.list-title{mso-fareast-font-family:"Arial Narrow";mso-bidi-font-family: "Arial Narrow";font-variant:normal !important;text-transform:uppercase;}
.list-title-number{mso-list:Ignore}
.list-title-space{font:7.0pt "Times New Roman"}
.doc-table{width:450.75pt;margin-left:5.4pt;border-collapse:collapse;border:none; mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt solid windowtext;mso-border-insidev: .5pt solid windowtext}
.doc-table-row{border:solid windowtext 1.0pt; mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;}
.doc-table-row:first-child{border-top:none;}
.doc-table-row.header{background:black;mso-background-alt:black;}
.doc-table-row.data{border-top:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt; mso-border-top-alt:solid windowtext .5pt;}
.doc-table-row.next{border-left:none;mso-border-left-alt:solid windowtext .5pt;}
.doc-table-row.header p {text-align:center;font-weight:bold;mso-bidi-font-weight:normal;color:white;}
.doc-table-row p.number{text-align:right;}
table.MsoNormalTable td {vertical-align:top;}
table.MsoNormalTable a{color:black;text-decoration:none;font-size:10pt;}
</style>
';
set @heading1 = '
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1252">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 15">
<meta name=Originator content="Microsoft Word 15">
<title>!DOC_TITLE!</title>
 ';
set @heading2 = '
<style>
<!--
/* Font Definitions */
@font-face{font-family:Helv;panose-1:2 11 6 4 2 2 2 3 2 4}
@font-face{font-family:Batang;panose-1:2 3 6 0 0 1 1 1 1 1}
@font-face{font-family:"Cambria Math";panose-1:2 4 5 3 5 4 6 3 2 4}
@font-face{font-family:Calibri;panose-1:2 15 5 2 2 2 4 3 2 4}
@font-face{font-family:"Arial Narrow";panose-1:2 11 6 6 2 2 2 3 2 4}
@font-face{font-family:"Book Antiqua";panose-1:2 4 6 2 5 3 5 3 3 4}
@font-face{font-family:Tahoma;panose-1:2 11 6 4 3 5 4 4 2 4}
@font-face{font-family:"\@Batang";panose-1:2 3 6 0 0 1 1 1 1 1}
p.MsoNormal,li.MsoNormal,div.MsoNormal{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
h1{mso-style-link:"Judul 1 KAR";text-align:justify;text-indent:-21.6pt;page-break-after:avoid;font-size:14pt;font-family:"Arial Narrow","sans-serif";font-variant:small-caps;font-weight:700;margin:12pt 0 6pt 21.6pt}
h2{mso-style-link:"Judul 2 KAR";text-align:justify;text-indent:-28.8pt;page-break-after:avoid;font-size:12pt;font-family:"Arial Narrow","sans-serif";font-variant:small-caps;font-weight:700;margin:6pt 0 3pt 28.8pt}
h3{mso-style-link:"Judul 3 KAR";text-align:justify;text-indent:-36pt;page-break-after:avoid;font-size:11pt;font-family:"Arial Narrow","sans-serif";font-variant:small-caps;font-weight:700;margin:3pt 0 3pt 36pt}
h4{mso-style-link:"Judul 4 KAR";text-align:justify;text-indent:-43.2pt;page-break-after:avoid;font-size:10pt;font-family:"Arial Narrow","sans-serif";font-weight:700;margin:3pt 0 3pt 43.2pt}
h5{mso-style-link:"Judul 5 KAR";margin-bottom:.0001pt;text-align:justify;text-indent:-50.4pt;font-size:10pt;font-family:"Arial Narrow","sans-serif";font-weight:700;margin:0 0 0 50.4pt}
h6{mso-style-link:"Judul 6 KAR";text-align:justify;text-indent:-57.6pt;font-size:11pt;font-family:"Arial Narrow","sans-serif";font-weight:400;font-style:italic;margin:12pt 0 3pt 57.6pt}
p.MsoHeading7,li.MsoHeading7,div.MsoHeading7{mso-style-link:"Judul 7 KAR";text-align:justify;text-indent:-64.8pt;font-size:10pt;font-family:"Arial","sans-serif";margin:12pt 0 3pt 64.8pt}
p.MsoHeading8,li.MsoHeading8,div.MsoHeading8{mso-style-link:"Judul 8 KAR";text-align:justify;text-indent:-72pt;font-size:10pt;font-family:"Arial","sans-serif";font-style:italic;margin:12pt 0 3pt 72pt}
p.MsoHeading9,li.MsoHeading9,div.MsoHeading9{mso-style-link:"Judul 9 KAR";text-align:justify;text-indent:-79.2pt;font-size:9pt;font-family:"Arial","sans-serif";font-weight:700;font-style:italic;margin:12pt 0 3pt 79.2pt}
p.MsoToc1,li.MsoToc1,div.MsoToc1{text-align:justify;font-size:10pt;font-family:"Calibri","sans-serif";text-transform:uppercase;font-weight:700;margin:6pt 0}
p.MsoToc2,li.MsoToc2,div.MsoToc2{margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Calibri","sans-serif";font-variant:small-caps;margin:0 0 0 10pt}
p.MsoToc3,li.MsoToc3,div.MsoToc3{margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Calibri","sans-serif";font-style:italic;margin:0 0 0 20pt}
p.MsoToc4,li.MsoToc4,div.MsoToc4{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:9pt;font-family:"Arial Narrow","sans-serif"}
p.MsoToc5,li.MsoToc5,div.MsoToc5{margin-bottom:.0001pt;text-align:justify;font-size:9pt;font-family:"Calibri","sans-serif";margin:0 0 0 40pt}
p.MsoToc6,li.MsoToc6,div.MsoToc6{margin-bottom:.0001pt;text-align:justify;font-size:9pt;font-family:"Calibri","sans-serif";margin:0 0 0 50pt}
p.MsoToc7,li.MsoToc7,div.MsoToc7{margin-bottom:.0001pt;text-align:justify;font-size:9pt;font-family:"Calibri","sans-serif";margin:0 0 0 60pt}
p.MsoToc8,li.MsoToc8,div.MsoToc8{margin-bottom:.0001pt;text-align:justify;font-size:9pt;font-family:"Calibri","sans-serif";margin:0 0 0 70pt}
p.MsoToc9,li.MsoToc9,div.MsoToc9{margin-bottom:.0001pt;text-align:justify;font-size:9pt;font-family:"Calibri","sans-serif";margin:0 0 0 80pt}
p.MsoNormalIndent,li.MsoNormalIndent,div.MsoNormalIndent{text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0 6pt 36pt}
p.MsoFootnoteText,li.MsoFootnoteText,div.MsoFootnoteText{mso-style-link:"Teks Catatan Kaki KAR";margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
p.MsoCommentText,li.MsoCommentText,div.MsoCommentText{text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0}
p.MsoHeader,li.MsoHeader,div.MsoHeader{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";font-weight:700}
p.MsoFooter,li.MsoFooter,div.MsoFooter{mso-style-link:"Footer KAR";margin:0;margin-bottom:.0001pt;text-align:justify;font-size:8pt;font-family:"Arial Narrow","sans-serif"}
p.MsoCaption,li.MsoCaption,div.MsoCaption{text-align:center;font-size:9pt;font-family:"Arial Narrow","sans-serif";margin:0 0 3pt}
p.MsoTof,li.MsoTof,div.MsoTof{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
span.MsoFootnoteReference{font-family:"Arial","sans-serif";vertical-align:super}
span.MsoCommentReference{font-family:"Arial","sans-serif"}
span.MsoLineNumber{font-family:"Arial","sans-serif"}
span.MsoPageNumber{font-family:"Arial","sans-serif"}
span.MsoEndnoteReference{font-family:"Arial","sans-serif";vertical-align:super}
p.MsoEndnoteText,li.MsoEndnoteText,div.MsoEndnoteText{mso-style-link:"Teks Catatan Akhir KAR";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0}
p.MsoListBullet,li.MsoListBullet,div.MsoListBullet{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
p.MsoListNumber,li.MsoListNumber,div.MsoListNumber{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
p.MsoListBullet2,li.MsoListBullet2,div.MsoListBullet2{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
p.MsoListBullet3,li.MsoListBullet3,div.MsoListBullet3{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
p.MsoListNumber2,li.MsoListNumber2,div.MsoListNumber2{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
p.MsoTitle,li.MsoTitle,div.MsoTitle{margin:0;margin-bottom:.0001pt;text-align:right;font-size:22pt;font-family:"Arial Narrow","sans-serif";font-weight:700;font-style:italic}
p.MsoBodyText,li.MsoBodyText,div.MsoBodyText{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:8pt;font-family:"Arial Narrow","sans-serif"}
p.MsoBodyTextIndent,li.MsoBodyTextIndent,div.MsoBodyTextIndent{margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 18pt}
p.MsoSubtitle,li.MsoSubtitle,div.MsoSubtitle{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:14pt;font-family:"Arial Narrow","sans-serif"}
p.MsoDate,li.MsoDate,div.MsoDate{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Times New Roman","serif"}
p.MsoBodyText2,li.MsoBodyText2,div.MsoBodyText2{margin-bottom:.0001pt;text-align:justify;punctuation-wrap:simple;text-autospace:none;font-size:12pt;font-family:"Times New Roman","serif";margin:0 -4.5pt 0 0}
p.MsoBodyText3,li.MsoBodyText3,div.MsoBodyText3{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";layout-grid-mode:line}
p.MsoBodyTextIndent2,li.MsoBodyTextIndent2,div.MsoBodyTextIndent2{margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 36pt}
p.MsoBodyTextIndent3,li.MsoBodyTextIndent3,div.MsoBodyTextIndent3{margin-bottom:.0001pt;text-align:justify;text-indent:-18pt;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 36pt}
a:link,span.MsoHyperlink{font-family:"Arial","sans-serif";color:blue;text-decoration:underline}';
set @heading3 = '
a:visited,span.MsoHyperlinkFollowed{font-family:"Arial","sans-serif";color:purple;text-decoration:underline}
strong{font-family:"Arial","sans-serif"}
em{font-family:"Arial","sans-serif";font-style:normal}
p.MsoDocumentMap,li.MsoDocumentMap,div.MsoDocumentMap{mso-style-link:"Peta Dokumen KAR";text-align:justify;background:navy;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0}
p.MsoPlainText,li.MsoPlainText,div.MsoPlainText{text-align:justify;font-size:10pt;font-family:"Courier New";margin:6pt 0 2pt 36pt}
p{margin:0;margin-bottom:.0001pt;text-align:justify;font-size:12pt;font-family:"Arial Narrow","sans-serif"}
acronym{font-family:"Arial","sans-serif"}
cite{font-family:"Arial","sans-serif";font-style:normal}
dfn{font-family:"Arial","sans-serif";font-style:normal}
var{font-family:"Arial","sans-serif";font-style:normal}
p.MsoAcetate,li.MsoAcetate,div.MsoAcetate{mso-style-link:"Teks Balon KAR";margin:0;margin-bottom:.0001pt;text-align:justify;font-size:8pt;font-family:"Tahoma","sans-serif"}
span.MsoPlaceholderText{color:gray}
p.MsoListParagraph,li.MsoListParagraph,div.MsoListParagraph{margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 36pt}
p.MsoListParagraphCxSpFirst,li.MsoListParagraphCxSpFirst,div.MsoListParagraphCxSpFirst{margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 36pt}
p.MsoListParagraphCxSpMiddle,li.MsoListParagraphCxSpMiddle,div.MsoListParagraphCxSpMiddle{margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 36pt}
p.MsoListParagraphCxSpLast,li.MsoListParagraphCxSpLast,div.MsoListParagraphCxSpLast{margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 36pt}
span.MsoSubtleEmphasis{color:gray;font-style:italic}
span.MsoIntenseEmphasis{color:#4F81BD;font-weight:700;font-style:italic}
p.indent1,li.indent1,div.indent1{mso-style-name:indent1;margin-bottom:.0001pt;text-align:justify;text-indent:-27pt;font-size:10pt;font-family:"Arial","sans-serif";margin:0 0 0 45pt}
p.heading,li.heading,div.heading{mso-style-name:heading;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";font-weight:700;margin:6pt 0}
p.Normal2,li.Normal2,div.Normal2{mso-style-name:"Normal 2";margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 72pt}
p.Normal1,li.Normal1,div.Normal1{mso-style-name:"Normal 1";margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 36pt}
p.Bullet1,li.Bullet1,div.Bullet1{mso-style-name:"Bullet 1";margin-bottom:.0001pt;text-align:justify;text-indent:-18pt;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 54pt}
p.Bullet2,li.Bullet2,div.Bullet2{mso-style-name:"Bullet 2";margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 54pt}
p.Bullet3,li.Bullet3,div.Bullet3{mso-style-name:"Bullet 3";margin:0;margin-bottom:.0001pt;text-align:justify;text-indent:0;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
p.Number1,li.Number1,div.Number1{mso-style-name:"Number 1";margin-bottom:.0001pt;text-align:justify;text-indent:25.2pt;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 10.8pt}
p.Number2,li.Number2,div.Number2{mso-style-name:"Number 2";margin-bottom:.0001pt;text-align:justify;text-indent:18pt;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 36pt}
p.TableHeader,li.TableHeader,div.TableHeader{mso-style-name:"Table Header";margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";font-weight:700;margin:0 0 0 36pt}
p.Normal3,li.Normal3,div.Normal3{mso-style-name:"Normal 3";text-align:left;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 6pt 72pt}
p.Normal4,li.Normal4,div.Normal4{mso-style-name:"Normal 4";text-align:left;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 6pt 144.05pt}
p.THeader,li.THeader,div.THeader{mso-style-name:"T Header";text-align:center;font-size:10pt;font-family:"Arial Narrow","sans-serif";font-weight:700;margin:6pt 0}
p.Point1,li.Point1,div.Point1{mso-style-name:"Point 1";text-align:justify;font-size:10pt;font-family:"Arial","sans-serif";margin:6pt 0 6pt 36pt}
p.Point,li.Point,div.Point{mso-style-name:Point;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0}
p.Point2,li.Point2,div.Point2{mso-style-name:"Point 2";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0 6pt 72.05pt}
p.Point3,li.Point3,div.Point3{mso-style-name:"Point 3";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0 6pt 108.05pt}
p.Point4,li.Point4,div.Point4{mso-style-name:"Point 4";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0 6pt 144.05pt}
p.Point5,li.Point5,div.Point5{mso-style-name:"Point 5";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0 6pt 180.05pt}
p.Point6,li.Point6,div.Point6{mso-style-name:"Point 6";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0 6pt 216pt}
p.Point7,li.Point7,div.Point7{mso-style-name:"Point 7";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0 6pt 252.05pt}
p.TCell,li.TCell,div.TCell{mso-style-name:"T Cell";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0}
p.Regards,li.Regards,div.Regards{mso-style-name:Regards;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:24pt 0 36pt}
p.CodeExample,li.CodeExample,div.CodeExample{mso-style-name:"Code Example";margin:0;margin-bottom:.0001pt;text-align:left;font-size:8pt;font-family:"Courier New"}
p.Normal0,li.Normal0,div.Normal0{mso-style-name:"Normal 0";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:6pt 0}
p.uNormal,li.uNormal,div.uNormal{mso-style-name:uNormal;text-align:justify;font-size:10pt;font-family:"Times New Roman","serif";margin:0 0 6pt 144pt}
p.trgtext,li.trgtext,div.trgtext{mso-style-name:trgtext;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 -36pt 0 144pt}
p.Normal10,li.Normal10,div.Normal10{mso-style-name:Normal1;text-align:justify;font-size:11pt;font-family:"Arial Narrow","sans-serif";margin:6pt -30.05pt 6pt 36pt}
p.Normal20,li.Normal20,div.Normal20{mso-style-name:Normal2;text-align:justify;text-indent:-36pt;font-size:11pt;font-family:"Arial Narrow","sans-serif";font-weight:700;margin:6pt 0 6pt 36pt}
p.Resume3,li.Resume3,div.Resume3{mso-style-name:Resume3;margin-bottom:.0001pt;text-align:justify;text-indent:-28.1pt;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 0 28.1pt}
span.HighlightedVariable{mso-style-name:"Highlighted Variable";color:blue}
p.HeadingBar,li.HeadingBar,div.HeadingBar{mso-style-name:"Heading Bar";margin-bottom:.0001pt;text-align:justify;page-break-after:avoid;background:#000;punctuation-wrap:simple;text-autospace:none;font-size:4pt;font-family:"Times New Roman","serif";color:#fff;margin:12pt 396pt 0 0}
p.Bullet,li.Bullet,div.Bullet{mso-style-name:Bullet;text-align:justify;text-indent:-18pt;font-size:10pt;font-family:"Times New Roman","serif";margin:3pt 0 3pt 18pt}
p.TableHeading,li.TableHeading,div.TableHeading{mso-style-name:"Table Heading";text-align:justify;punctuation-wrap:simple;text-autospace:none;font-size:8pt;font-family:"Times New Roman","serif";font-weight:700;margin:6pt 0}
p.TableText,li.TableText,div.TableText{mso-style-name:"Table Text";margin:0;margin-bottom:.0001pt;text-align:justify;punctuation-wrap:simple;text-autospace:none;font-size:8pt;font-family:"Times New Roman","serif"}';
set @heading4 = '
p.hangingindent,li.hangingindent,div.hangingindent{mso-style-name:"hanging indent";text-align:justify;text-indent:-144pt;font-size:10pt;font-family:"Book Antiqua","serif";margin:6pt 0 6pt 270pt}
p.BodyText21,li.BodyText21,div.BodyText21{mso-style-name:"Body Text 21";text-align:justify;font-size:10pt;font-family:"Times New Roman","serif";margin:6pt 0 2pt 36pt}
p.tty80,li.tty80,div.tty80{mso-style-name:tty80;margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Courier New"}
p.Bullets,li.Bullets,div.Bullets{mso-style-name:Bullets;text-align:justify;text-indent:-18pt;font-size:10pt;font-family:"Times New Roman","serif";margin:0 0 2pt 54pt}
p.NumberList,li.NumberList,div.NumberList{mso-style-name:"Number List";text-align:justify;text-indent:-18pt;font-size:10pt;font-family:"Book Antiqua","serif";margin:3pt 0 3pt 54pt}
p.tty80indent,li.tty80indent,div.tty80indent{mso-style-name:"tty80 indent";margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Courier New";margin:0 0 0 144.75pt}
p.REPORTTEXT,li.REPORTTEXT,div.REPORTTEXT{mso-style-name:"REPORT TEXT";margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Courier New";color:#000}
p.NCAIndentText,li.NCAIndentText,div.NCAIndentText{mso-style-name:"NCA Indent Text";text-align:justify;font-size:10pt;font-family:"Book Antiqua","serif";margin:0 0 10pt 108pt}
span.JavaCode{mso-style-name:"Java Code";font-family:"Courier New"}
span.Code{mso-style-name:Code;font-family:"Courier New"}
p.PrefaceText,li.PrefaceText,div.PrefaceText{mso-style-name:"Preface Text";margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Helv","sans-serif"}
p.BulletPoint,li.BulletPoint,div.BulletPoint{mso-style-name:"Bullet Point";text-align:justify;text-indent:0;font-size:12pt;font-family:"Book Antiqua","serif";margin:0 0 6pt}
p.ExampleCode,li.ExampleCode,div.ExampleCode{mso-style-name:"Example Code";margin-bottom:.0001pt;text-align:justify;border:none;padding:0;font-size:9pt;font-family:"Book Antiqua","serif";margin:0 72pt 0 54pt}
p.ABLOCKPARA,li.ABLOCKPARA,div.ABLOCKPARA{mso-style-name:"A BLOCK PARA";margin:0;margin-bottom:.0001pt;text-align:justify;font-size:11pt;font-family:"Arial Narrow","sans-serif"}
p.CodeListing,li.CodeListing,div.CodeListing{mso-style-name:CodeListing;margin-bottom:.0001pt;text-align:justify;font-size:9pt;font-family:"Courier New";color:#000;margin:0 0 0 108pt}
p.Codeindent,li.Codeindent,div.Codeindent{mso-style-name:"Code indent";margin-bottom:.0001pt;text-align:justify;font-size:9pt;font-family:"Courier New";layout-grid-mode:line;margin:0 0 0 108pt}
p.BulletIndent0,li.BulletIndent0,div.BulletIndent0{mso-style-name:"Bullet Indent 0";margin-bottom:.0001pt;text-align:justify;text-indent:-18pt;line-height:15pt;font-size:10pt;font-family:"Book Antiqua","serif";margin:0 0 0 54pt}
p.NormalIndent3,li.NormalIndent3,div.NormalIndent3{mso-style-name:"Normal Indent3";text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";margin:0 0 12pt 54pt}
p.DesignSections,li.DesignSections,div.DesignSections{mso-style-name:"Design Sections";margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif"}
span.TeksBalonKAR{mso-style-name:"Teks Balon KAR";mso-style-link:"Teks Balon";font-family:"Tahoma","sans-serif"}
span.Judul2KAR{mso-style-name:"Judul 2 KAR";mso-style-link:"Judul 2";font-family:"Arial Narrow","sans-serif";font-variant:small-caps;font-weight:700}
span.Judul3KAR{mso-style-name:"Judul 3 KAR";mso-style-link:"Judul 3";font-family:"Arial Narrow","sans-serif";font-variant:small-caps;font-weight:700}
span.Judul9KAR{mso-style-name:"Judul 9 KAR";mso-style-link:"Judul 9";font-family:"Arial","sans-serif";font-weight:700;font-style:italic}
span.TeksCatatanAkhirKAR{mso-style-name:"Teks Catatan Akhir KAR";mso-style-link:"Teks Catatan Akhir";font-family:"Arial","sans-serif"}
span.FooterKAR{mso-style-name:"Footer KAR";mso-style-link:Footer;font-family:"Arial","sans-serif"}
p.H4,li.H4,div.H4{mso-style-name:H4;text-align:justify;page-break-after:avoid;font-size:12pt;font-family:"Times New Roman","serif";layout-grid-mode:line;font-weight:700;margin:5pt 0}
span.Judul4KAR{mso-style-name:"Judul 4 KAR";mso-style-link:"Judul 4";font-family:"Arial Narrow","sans-serif";font-weight:700}
span.TeksCatatanKakiKAR{mso-style-name:"Teks Catatan Kaki KAR";mso-style-link:"Teks Catatan Kaki";font-family:"Arial Narrow","sans-serif"}
p.ReferenceLink,li.ReferenceLink,div.ReferenceLink{mso-style-name:"Reference Link";margin:0;margin-bottom:.0001pt;text-align:justify;font-size:10pt;font-family:"Arial Narrow","sans-serif";text-decoration:underline}
span.Judul1KAR{mso-style-name:"Judul 1 KAR";mso-style-link:"Judul 1";font-family:"Arial Narrow","sans-serif";font-variant:small-caps;font-weight:700}
span.Judul5KAR{mso-style-name:"Judul 5 KAR";mso-style-link:"Judul 5";font-family:"Arial Narrow","sans-serif";font-weight:700}
span.Judul6KAR{mso-style-name:"Judul 6 KAR";mso-style-link:"Judul 6";font-family:"Arial Narrow","sans-serif";font-style:italic}
span.Judul7KAR{mso-style-name:"Judul 7 KAR";mso-style-link:"Judul 7";font-family:"Arial","sans-serif"}
span.Judul8KAR{mso-style-name:"Judul 8 KAR";mso-style-link:"Judul 8";font-family:"Arial","sans-serif";font-style:italic}
span.PetaDokumenKAR{mso-style-name:"Peta Dokumen KAR";mso-style-link:"Peta Dokumen";font-family:"Arial Narrow","sans-serif";background:navy}
.MsoChpDefault{font-size:10pt}
@page WordSection1{size:595.45pt 841.7pt;margin:77.05pt 72pt 64.1pt}
div.WordSection1{page:WordSection1}
ol{margin-bottom:0}
ul{margin-bottom:0}
/-->
</style>
<body link=blue vlink=purple>

<div class=WordSection1>
';
set @headingDatabase = '
<h1 style="mso-list:l17 level1 lfo7">
	<span class="list-title">
		<span class="list-title">!DOC_START_HEADING1!<span class="list-title-space">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span>
	</span>
	<span class="text-title">Database</span>
</h1>
<p class=MsoNormal>!DESCRIPTION!</p>

<h2 style="mso-list:l17 level2 lfo7">
	<span class="list-title">
		<span class="list-title-number">!DOC_START_HEADING1!.!DOC_START_HEADING2!<span class="list-title-space">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span>
	</span>
	<span class="text-title">Table Definition</span>
</h2>
';

declare
	@tableIterator int, @tableId int , @tableNo int, @tableDescription varchar(max), @tableName varchar(max),
	@description varchar(max),
	@columnIterator int, @columnNo int, @columnDescription varchar(max), @columnName varchar(max), @columnType varchar(max), @columnIsNullable varchar(max);

/***************************************************************/
/* END: Configuration                                          */
/***************************************************************/
/***************************************************************/
/* START: Data preparation                                     */
/***************************************************************/
set nocount on;
--columns
if object_id('TempDB..#column') is not null
	drop table #column;
select 
	object_definition(c.default_object_id) DefaultValue, 
	case
		when t.name in ('bit', 'int', 'tinyint', 'smallint', 'bigint') then 2
		when t.name in ('datetime', 'date', 'datetime2') then 1
		when t.name in ('varchar', 'char', 'text') then 1
		when t.name in ('nvarchar', 'nchar') then 2
		else 0
	end LeftSubstractor,
	case
		when t.name in ('bit', 'int', 'tinyint', 'smallint', 'bigint') then 2
		when t.name in ('datetime', 'date', 'datetime2') then 1
		when t.name in ('varchar', 'char', 'nvarchar', 'nchar', 'text') then 1
		else 0
	end RightSubstractor,
	c.* 
into #column 
from sys.columns c
left join sys.types t on c.system_type_id = t.system_type_id and c.user_type_id = t.user_type_id;
--table
if object_id('TempDB..#table') is not null
	drop table #table;
select ROW_NUMBER() OVER(order by name asc) RowNumber, * 
into #table 
from sys.tables
where [type] = 'U';
--extended properties
if object_id('TempDB..#extended_properties') is not null
	drop table #extended_properties;
select * into #extended_properties from sys.extended_properties;
--type
if object_id('TempDB..#type') is not null
	drop table #type;
select * into #type from sys.types;
--foreign_keys
if object_id('TempDB..#foreign_keys') is not null
	drop table #foreign_keys;
select * into #foreign_keys from sys.foreign_keys;
--foreign_key_columns
if object_id('TempDB..#foreign_key_columns') is not null
	drop table #foreign_key_columns;
select * into #foreign_key_columns from sys.foreign_key_columns;
--indexes
if object_id('TempDB..#indexes') is not null
	drop table #indexes;
select * into #indexes from sys.indexes;
--index_columns
if object_id('TempDB..#index_columns') is not null
	drop table #index_columns;
select * into #index_columns from sys.index_columns;
--computed_columns
if object_id('TempDB..#computed_columns') is not null
	drop table #computed_columns;
select * into #computed_columns from sys.computed_columns;
/***************************************************************/
/* END: Data preparation                                       */
/***************************************************************/
--get database description
select @description = convert(varchar(1000), value)
from #extended_properties 
where
	class = 0 
	and major_id = 0 
	and minor_id = 0 
	and name = 'MS_Description';
print replace(@heading1, '!DOC_TITLE!', @docTitle);
print @heading2;
print @heading3;
print @heading4;
print @styles;
print replace(replace(replace(@headingDatabase, '!DOC_START_HEADING1!', @docStartHeading1), '!DOC_START_HEADING2!', @docStartHeading2), '!DESCRIPTION!', @description);
set @tableIterator = 1;
while exists (select 1 from #table where RowNumber = @tableIterator)
begin
	--get table information
	select
		@tableId = t.object_id,
		@tableName = t.name,
		@tableNo = t.RowNumber
	from #table t
	where t.RowNumber = @tableIterator;
	select @tableDescription = convert(varchar(1000), ep.value)
	from #extended_properties ep
	where ep.major_id = @tableId and ep.minor_id = 0 and ep.name = 'MS_Description';
	--print table information
	print replace(replace(replace(replace(replace(replace(@formatTableHead, '!TABLE_ID!', @tableId), '!DOC_START_HEADING1!', @docStartHeading1), '!DOC_START_HEADING2!', @docStartHeading2), '!TABLE_NO!', @tableNo), '!TABLE_NAME!', @tableName), '!DESCRIPTION!', @tableDescription);	set @tableIterator = @tableIterator + 1;
	print @docTableOpen;
	set @columnIterator = 1;
	while exists(select 1 from #column sc where sc.object_id = @tableId and sc.column_id = @columnIterator)
	begin
		select 
			@columnNo = sc.column_id,
			@columnName = sc.name,
			@columnType = case
				when [type].name in ('nvarchar', 'varchar', 'nchar', 'char', 'binary') and sc.max_length = -1 then [type].name + '(max)'
				when [type].name in ('nvarchar', 'varchar', 'nchar', 'char', 'binary') and sc.max_length <> -1 then [type].name + '(' + cast(sc.max_length as varchar) + ')'
				when [type].name in ('decimal', 'numeric') then [type].name + '(' + cast(sc.precision as varchar) + ',' + cast(sc.scale as varchar) +')'
				when [type].name in ('datetime2') then [type].name + '(' + cast(sc.scale as varchar) + ')'
				else [type].name
			end,
			@columnIsNullable = case sc.is_nullable
				when 1 then 'yes'
				else 'no'
			end,
			@columnDescription = case when pk.ColumnId is not null then 'Primary Key. ' else '' end +
			case when sc.is_identity = 1 then 'Auto increment. ' else '' end +
			case when fk.ColumnTargetId is not null then replace(replace(replace(@formatForeignKey, '!TABLE_ID!', fk.TableTargetId), '!TABLE_NAME!', fk.TableTargetName), '!COLUMN_NAME!', fk.ColumnTargetName) else '' end + 
			case when cc.Formula is not null then 'Computed -> ' + substring(cc.Formula, 2, len(cc.Formula) - 2) + '. ' else '' end +
			case when sep.value is not null then cast(sep.value as varchar(max)) else '' end + ' ' +
			case when sc.DefaultValue is not null then 'Default: ' + substring(sc.DefaultValue, sc.LeftSubstractor + 1, len(sc.DefaultValue) - sc.LeftSubstractor - sc.RightSubstractor) + '. ' else '' end
		from #table st
		inner join #column sc on st.object_id = sc.object_id
		left join #type [type] on 
			sc.system_type_id = [type].system_type_id
			and sc.user_type_id = [type].user_type_id
		left join #extended_properties sep on 
			st.object_id = sep.major_id
			and sc.column_id = sep.minor_id
			and sep.name = 'MS_Description'
		--search for foreign key
		left join (
			select 
				fk.name RelationName,
				t1.object_id TableSourceId,
				t1.name TableSourceName,
				sc1.column_id ColumnSourceId,
				sc1.name ColumnSourceName,
				t2.object_id TableTargetId,
				t2.name TableTargetName,
				sc2.column_id ColumnTargetId,
				sc2.name ColumnTargetName
			from #foreign_keys fk
			left join #table t1 on fk.parent_object_id = t1.object_id
			left join #table t2 on fk.referenced_object_id = t2.object_id
			left join #foreign_key_columns fkc on fk.object_id = fkc.constraint_object_id
			left join #column sc1 on t1.object_id = sc1.object_id and sc1.column_id = fkc.parent_column_id
			left join #column sc2 on t2.object_id = sc2.object_id and sc2.column_id = fkc.referenced_column_id
			where
				t1.name = @tableName
		) fk on 
			fk.TableSourceId = st.object_id
			and sc.column_id = fk.ColumnSourceId
		--search for primary key
		left join (
			select
				i.object_id TableId,
				c.column_id ColumnId,
				c.name ColumnName
			from #indexes i
			left join #index_columns ic on 
				i.object_id = ic.object_id
				and i.index_id = ic.index_id
			left join #column c on 
				i.object_id = c.object_id
				and ic.column_id = c.column_id
			left join #table t on i.object_id = t.object_id
			where
				t.name = @tableName
				and i.is_primary_key = 1
		) pk on 
			st.object_id = pk.TableId
			and sc.column_id = pk.ColumnId
		--search for computed columns
		left join (
			select 
				cc.object_id TableId,
				cc.column_id ColumnId,
				cc.definition Formula
			from #computed_columns cc
		) cc on 
			cc.TableId = st.object_id
			and cc.ColumnId = sc.column_id
		where
			st.name = @tableName
			and st.object_id = @tableId
			and sc.column_id = @columnIterator
		order by sc.column_id asc;
		print replace(replace(replace(replace(replace(@formatColumn, '!COLUMN_NO!', @columnNo), '!COLUMN_NAME!', @columnName), '!COLUMN_TYPE!', @columnType), '!COLUMN_ISNULLABLE!', @columnIsNullable), '!COLUMN_DESCRIPTION!', @columnDescription);
		set @columnIterator = @columnIterator + 1;
	end
	print @docTableClose;
end
print @docClosing;
set nocount off;
drop table #table;
drop table #column;
drop table #computed_columns;
drop table #extended_properties;
drop table #foreign_key_columns;
drop table #foreign_keys;
drop table #index_columns;
drop table #indexes;
drop table #type;