<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="ihm1507069875331" id="ihm1507069875331"><h1 class="title topictitle1" id="ariaid-title1">ShapleyAddOnePlayer (ML Engine)</h1><div class="body conbody">
<p class="p">The ShapleyAddOnePlayer function takes a table of sorted combinations, output by either <a href="rem1558448554625.md#ixr1510338180588">ShapleyGenerateCombination (ML Engine)</a> or <a href="vrt1558448640648.md#jtk1507069294341">ShapleySortCombinations (ML Engine)</a>, and outputs a table. The ShapleyAddOnePlayer input and output tables are queried by the <a href="mao1507070359696.md">SQL Statements to Compute the Shapley Value</a>.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="dgy1507069934741" xml:lang="en-us" lang="en-us" id="dgy1507069934741">
<h2 class="title topictitle2" id="ariaid-title2">ShapleyAddOnePlayer Syntax</h2><div class="body refbody"><div class="section" id="dgy1507069934741__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version <span>1.5</span></h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM ShapleyAddOnePlayer (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY <var class="keyword varname">key</var>
  USING
  CombinationColumn ('<var class="keyword varname">combination_column</var>')
  SizeColumn ('<var class="keyword varname">size_column</var>')
  ValueColumn ('<var class="keyword varname">value_column</var>')
  NumPlayers (<var class="keyword varname">number_of_players</var>)
  [ Delimiter ('<var class="keyword varname">delimiter</var>') ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="vme1507070009738" xml:lang="en-us" lang="en-us" id="vme1507070009738">
<h2 class="title topictitle2" id="ariaid-title3">ShapleyAddOnePlayer Syntax Elements</h2><div class="body refbody"><div class="section" id="vme1507070009738__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">CombinationColumn</dt><dd class="dd pd">Specify the name of the input table column that contains the combinations.</dd><dt class="dt pt dlterm">SizeColumn</dt><dd class="dd pd">Specify the name of the input table column that contains the size of each combination.</dd><dt class="dt pt dlterm">ValueColumn</dt><dd class="dd pd">Specify the name of the input table column that contains the characteristic value of each combination.</dd><dt class="dt pt dlterm">NumPlayers</dt><dd class="dd pd">Specify the number of players in the game, a positive integer.</dd><dt class="dt pt dlterm">Delimiter</dt><dd class="dd pd">[Optional] Specify the character that separates player numbers in combinations. The value of <var class="keyword varname">delimiter</var> must be one of the following:
<ul class="ul" id="vme1507070009738__ul_ug4_p55_4x">
<li class="li">' ' (space) (Default)</li>
<li class="li">',' (comma)</li>
<li class="li">';' (semicolon)</li>
<li class="li">'.' (period)</li>
<li class="li">'#' (pound sign)</li>
<li class="li">'%' (percent sign)</li>
<li class="li">'&amp;' (ampersand)</li></ul></dd></dl></div></div></div></div>
