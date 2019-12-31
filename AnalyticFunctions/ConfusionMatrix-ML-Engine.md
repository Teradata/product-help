<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="cpu1507655644292" id="cpu1507655644292"><h1 class="title topictitle1" id="ariaid-title1">ConfusionMatrix (ML Engine)</h1><div class="body conbody">
<p class="p">The ConfusionMatrix function shows how often a classification algorithm correctly classifies items. The function takes an input table that includes two columns—one containing the observed class of an item and the other containing the class predicted by the algorithm—and outputs three tables:</p>
<ul class="ul" id="cpu1507655644292__ul_xdl_sjl_p1b">
<li class="li">A confusion matrix (also called a contingency table), which shows the performance of the algorithm</li>
<li class="li">A table of overall statistics</li>
<li class="li">A table of statistics for each class</li></ul></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="dox1507655858929" xml:lang="en-us" lang="en-us" id="dox1507655858929">
<h2 class="title topictitle2" id="ariaid-title2">ConfusionMatrix Syntax</h2><div class="body refbody"><div class="section" id="dox1507655858929__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version <span>2.8</span></h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM ConfusionMatrix (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY 1
  OUT TABLE CountTable (<var class="keyword varname">count_table</var>)
  OUT TABLE StatTable (<var class="keyword varname">stat_table</var>)
  OUT TABLE AccuracyTable (<var class="keyword varname">accuracy_table</var>)
  USING
  ObservationColumn ('<var class="keyword varname">observed_column</var>')
  PredictColumn ('<var class="keyword varname">predicted_column</var>')
  [ Classes ('<var class="keyword varname">class</var>' [,...] ) ]
  [ Prevalence (<var class="keyword varname">prevalence</var> [,...] ) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="tap1507655872979" xml:lang="en-us" lang="en-us" id="tap1507655872979">
<h2 class="title topictitle2" id="ariaid-title3">ConfusionMatrix Syntax Elements</h2><div class="body refbody"><div class="section" id="tap1507655872979__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">CountTable</dt><dd class="dd pd">Specify the name of the confusion matrix, an output table.</dd><dt class="dt pt dlterm">StatTable</dt><dd class="dd pd">Specify the name of the output table of overall statistics.</dd><dt class="dt pt dlterm">AccuracyTable</dt><dd class="dd pd">Specify the name of the output table of statistics for each class.</dd><dt class="dt pt dlterm">ObservationColumn</dt><dd class="dd pd">Specify the name of the input column that contains the observed class.</dd><dt class="dt pt dlterm">PredictColumn</dt><dd class="dd pd">Specify the name of the input column that contains the predicted class.</dd><dt class="dt pt dlterm">Classes</dt><dd class="dd pd">[Optional] Specify the classes to output in the AccuracyTable. </dd><dd class="dd pd ddexpand">Default: All classes</dd><dt class="dt pt dlterm">Prevalence</dt><dd class="dd pd">[Optional] Specify the prevalences for the classes to output in the AccuracyTable. Therefore, if you specify Prevalence, you must also specify Classes, and for every <var class="keyword varname">class</var>, you must specify a <var class="keyword varname">prevalence</var>. Each <var class="keyword varname">prevalence</var> is a numeric value.</dd></dl></div></div></div></div>
