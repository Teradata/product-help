<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="fti1507841304899" id="fti1507841304899"><h1 class="title topictitle1" id="ariaid-title1">Antiselect_MLE (ML Engine)</h1><div class="body conbody">
<p class="p">Antiselect_MLE returns all columns <span>except</span> those specified in the Exclude syntax element.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="gzm1507841531530" xml:lang="en-us" lang="en-us" id="gzm1507841531530">
<h2 class="title topictitle2" id="ariaid-title2">Antiselect_MLE Syntax</h2><div class="body refbody"><div class="section" id="gzm1507841531530__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version 1.2</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM Antiselect_MLE (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span>
  USING 
  Exclude ({ '<var class="keyword varname">exclude_column</var>' | <var class="keyword varname">exclude_column_range</var> }[,...])
) AS <var class="keyword varname">alias</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="dyl1507841756631" xml:lang="en-us" lang="en-us" id="dyl1507841756631">
<h2 class="title topictitle2" id="ariaid-title3">Antiselect_MLE Syntax Elements</h2><div class="body refbody"><div class="section" id="dyl1507841756631__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">Exclude</dt><dd class="dd pd">Specify the names of the input table columns to exclude from the output table.</dd></dl></div></div></div></div>
