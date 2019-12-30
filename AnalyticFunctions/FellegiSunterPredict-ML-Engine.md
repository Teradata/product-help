<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="gti1507904102802" id="gti1507904102802"><h1 class="title topictitle1" id="ariaid-title1">FellegiSunterPredict (ML Engine)</h1><div class="body conbody">
<p class="p">The FellegiSunterPredict function predicts whether a pair of objects are
			duplicates.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="gyi1507904138422" xml:lang="en-us" lang="en-us" id="gyi1507904138422">
<h2 class="title topictitle2" id="ariaid-title2">FellegiSunterPredict Syntax</h2><div class="body refbody"><div class="section" id="gyi1507904138422__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version <span>1.6</span></h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM FellegiSunterPredict (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY ANY
  ON <var class="keyword varname">model_table</var> AS Model DIMENSION
  [ USING Accumulate ({ '<var class="keyword varname">accumulate_column</var>' | '<var class="keyword varname">accumulate_column_range</var>' }[,...]) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="zap1507904142317" xml:lang="en-us" lang="en-us" id="zap1507904142317">
<h2 class="title topictitle2" id="ariaid-title3">FellegiSunterPredict Syntax Elements</h2><div class="body refbody"><div class="section" id="zap1507904142317__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">Accumulate</dt><dd class="dd pd">[Optional] Specify the names of input table columns to copy to the output table.</dd></dl></div></div></div></div></body></html>
