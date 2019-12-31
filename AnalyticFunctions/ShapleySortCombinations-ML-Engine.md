<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="jtk1507069294341" id="jtk1507069294341"><h1 class="title topictitle1" id="ariaid-title1">ShapleySortCombinations (ML Engine)</h1><div class="body conbody">
<p class="p">The ShapleySortCombinations function takes a table of combinations, output by either the ShapleyGenerateCombination function or a SQL statement, and outputs a table of sorted combinations that can be input to <a href="ugs1558448732652.md#ihm1507069875331">ShapleyAddOnePlayer (ML Engine)</a>.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="too1507069351965" xml:lang="en-us" lang="en-us" id="too1507069351965">
<h2 class="title topictitle2" id="ariaid-title2">ShapleySortCombinations Syntax</h2><div class="body refbody"><div class="section" id="too1507069351965__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version <span>1.5</span></h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM ShapleySortCombinations (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span>
  USING
  CombinationColumn ('<var class="keyword varname">combination_column</var>')
  ValueColumn ('<var class="keyword varname">value_column</var>')
  [ Delimiter ('<var class="keyword varname">delimiter</var>') ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="lem1507069405716" xml:lang="en-us" lang="en-us" id="lem1507069405716">
<h2 class="title topictitle2" id="ariaid-title3">ShapleySortCombinations Syntax Elements</h2><div class="body refbody"><div class="section" id="lem1507069405716__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">CombinationColumn</dt><dd class="dd pd">Specify the name of the input table column that contains the combinations.</dd><dt class="dt pt dlterm">ValueColumn</dt><dd class="dd pd">Specify the name of the input table column that contains the assigned value of each combination.</dd><dt class="dt pt dlterm">Delimiter</dt><dd class="dd pd">[Optional] Specify the character that separates player numbers in combinations:
<ul class="ul" id="lem1507069405716__ul_ug4_p55_4x">
<li class="li">' ' (space) (Default)</li>
<li class="li">'#' (pound sign)</li>
<li class="li">'$' (dollar sign)</li>
<li class="li">'%' (percent sign)</li>
<li class="li">'&amp;' (ampersand)</li></ul></dd></dl></div></div></div></div>
