<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="vol1507670147308" id="vol1507670147308"><h1 class="title topictitle1" id="ariaid-title1">LinRegPredict (ML Engine)</h1><div class="body conbody">
<p class="p">The LinRegPredict function takes a model built by the <a href="vvr1558531705253.md#usr1507669357350">Linear Regression (ML Engine)</a> function and a test data set whose input attributes are the same as those in the model, and predicts the response variable for each observation in the test data set.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="esy1507670169042" xml:lang="en-us" lang="en-us" id="esy1507670169042">
<h2 class="title topictitle2" id="ariaid-title2">LinRegPredict Syntax</h2><div class="body refbody"><div class="section" id="esy1507670169042__section_N10011_N1000E_N10001">
<h3 class="title sectiontitle">Version 1.6</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM LinRegPredict (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable PARTITION BY ANY
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS Model DIMENSION
  [ USING
    [ TargetColumns ('<var class="keyword varname">target_column</var>' [,...]) ]
    [ Accumulate ('<var class="keyword varname">accumulate_column</var>' [,...]) ]
  ]
) AS <var class="keyword varname">alias</var>;
</code></pre></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="qkp1507670188437" xml:lang="en-us" lang="en-us" id="qkp1507670188437">
<h2 class="title topictitle2" id="ariaid-title3">LinRegPredict Syntax Elements</h2><div class="body refbody"><div class="section" id="qkp1507670188437__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">TargetColumns</dt><dd class="dd pd">[Optional] Specify the names of the InputTable columns that contain the input variables. You must specify these column names in the same order in which they appear in the model table. For example, suppose that the coefficient_index column of the model table has these values in this order:
<ul class="sl simple">
<li class="sli">intercept</li>
<li class="sli">housesize</li>
<li class="sli">lotsize</li>
<li class="sli">bedrooms</li>
<li class="sli">granite</li>
<li class="sli">upgradedbathroom</li></ul></dd><dd class="dd pd ddexpand">Then the TargetColumns syntax element must be:
<p class="p"><code class="ph codeph">TargetColumns ('housesize', 'lotsize', 'bedrooms','granite', 'upgradedbathroom').</code></p></dd><dd class="dd pd ddexpand">Otherwise, the function creates incorrect predictions.</dd><dd class="dd pd ddexpand">Default: All input columns</dd><dt class="dt pt dlterm">Accumulate</dt><dd class="dd pd">[Optional] Specify the names of InputTable columns to copy to the output table.</dd></dl></div></div></div></div>
