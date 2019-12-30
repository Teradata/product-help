<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="ipe1507736776455" id="ipe1507736776455"><h1 class="title topictitle1" id="ariaid-title1">PCAScore (ML Engine)</h1><div class="body conbody">
<p class="p">The <a href="cjv1558122294011.md#gax1507736538633">PCA (ML Engine)</a> function outputs a set of principal components, and each principal component is a linear combination of the set of original predictors.</p>
<p class="p">In the output table, table pca_health_ev_scaled, (from <a href="xmn1550807533239.md">PCA Example</a>) the first-ranked principal component is:</p>
<p class="p">-0.082 * age + 0.387 * bmi + (-0.0935) * bloodpressure + 0.042 * glucose …</p>
<p class="p">Using a similar equation, the PCAScore function uses the coefficients from the output table of the PCA function to compute a principal component score for each observation.</p>
<p class="p">A common use of PCAScore output is principal component regression (PCR).</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="xza1507736817767" xml:lang="en-us" lang="en-us" id="xza1507736817767">
<h2 class="title topictitle2" id="ariaid-title2">PCAScore Syntax</h2><div class="body refbody"><div class="section" id="xza1507736817767__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version 1.2</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM PCAScore (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable PARTITION BY ANY
  ON <var class="keyword varname">pca_table</var> AS PrCompTable DIMENSION ORDER BY component_rank
  USING
  Components (<var class="keyword varname">num_components</var>)
  <code class="ph codeph">[ Accumulate ({ '<var class="keyword varname">accumulate_column</var>' | <var class="keyword varname">accumulate_column_range</var> }[,...]) ]</code>
) AS <var class="keyword varname">alias</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="gyo1507736825801" xml:lang="en-us" lang="en-us" id="gyo1507736825801">
<h2 class="title topictitle2" id="ariaid-title3">PCAScore Syntax Elements</h2><div class="body refbody"><div class="section" id="gyo1507736825801__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">Components</dt><dd class="dd pd">Specify the number of principal components for which to calculate scores. The <var class="keyword varname">num_components</var> must be an integer not greater than the number of components (rows) in the PrCompTable.</dd><dt class="dt pt dlterm">Accumulate</dt><dd class="dd pd">[Optional] Specify the names of the InputTable columns to copy to the output table.</dd></dl></div></div></div></div></body></html>
