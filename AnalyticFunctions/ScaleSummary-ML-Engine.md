<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="uly1507825400157" id="uly1507825400157"><h1 class="title topictitle1" id="ariaid-title1">ScaleSummary (ML Engine)</h1><div class="body conbody"><div class="section" id="uly1507825400157__section_N1000E_N1000C_N10001">
<p class="p">The ScaleSummary function takes as input <a href="dzs1562074323660.md">ScaleMap Output</a> (statistics assembled at the vworker level) and outputs global statistical information for the entire input data set.</p></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="ejy1507825404484" xml:lang="en-us" lang="en-us" id="ejy1507825404484">
<h2 class="title topictitle2" id="ariaid-title2">ScaleSummary Syntax</h2><div class="body refbody"><div class="section" id="ejy1507825404484__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version <span>1.6</span></h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM ScaleSummary (
  ON (
    SELECT * FROM ScaleMap (
     ...
    ) AS <var class="keyword varname">alias_1</var>
  ) PARTITION BY 1
) AS <var class="keyword varname">alias_2</var>;</code></pre></div></div></div></div></body></html>
