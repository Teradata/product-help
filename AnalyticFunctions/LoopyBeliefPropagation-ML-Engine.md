<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="qxa1507825619114" id="qxa1507825619114"><h1 class="title topictitle1" id="ariaid-title1">LoopyBeliefPropagation (ML Engine)</h1><div class="body conbody">
<p class="p"><dfn class="term">Belief propagation</dfn>, or <dfn class="term">sum-product message passing</dfn>, is an algorithm for inferring probabilities
			from graphical models, such as Bayesian networks and Markov random fields.</p>
<p class="p">The LoopyBeliefPropagation function calculates, for a Bayesian network of
			binary variables, the marginal distribution for each unobserved variable, conditional on
			any observed variables.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="hcq1507825851640" xml:lang="en-us" lang="en-us" id="hcq1507825851640">
<h2 class="title topictitle2" id="ariaid-title2">LoopyBeliefPropagation Syntax</h2><div class="body refbody"><div class="section" id="hcq1507825851640__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version 1.5</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM LoopyBeliefPropagation (
  ON <var class="keyword varname">vertices_table</var> AS Vertices PARTITION BY <var class="keyword varname">vertex_key_column</var> [,...] 
  ON <var class="keyword varname">edges_table</var> AS Edges PARTITION BY <var class="keyword varname">source_vertex_key_column</var> [,...] 
  [ ON <var class="keyword varname">observation_table</var> AS ObservationTable PARTITION BY <var class="keyword varname">source_vertex_key_column</var> [,...] ]
  USING
  TargetKey ({ '<var class="keyword varname">target_key_column</var>' | <var class="keyword varname">target_key_column_range</var> }[,...])
  [ ObservationColumn ('<var class="keyword varname">observation_column</var>') ]
  [ EdgeWeight ('<var class="keyword varname">edge_weight</var>') ]
  [ Accumulate ('<var class="keyword varname">accumulate_column</var>') ] 
  [ MaxIterNum (<var class="keyword varname">max_iter_num</var>) ]
  [ StopThreshold (<var class="keyword varname">threshold</var>) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="qcy1507825893175" xml:lang="en-us" lang="en-us" id="qcy1507825893175">
<h2 class="title topictitle2" id="ariaid-title3">LoopyBeliefPropagation Syntax Elements</h2><div class="body refbody"><div class="section" id="qcy1507825893175__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">TargetKey</dt><dd class="dd pd">[Optional] Specify the names of the Edges table columns that comprise the key of the target vertices.</dd><dt class="dt pt dlterm">ObservationColumn</dt><dd class="dd pd">[Required with ObservationTable, optional otherwise.] Specify the name of the ObservationTable column that contains the observations.</dd><dt class="dt pt dlterm">EdgeWeight</dt><dd class="dd pd">[Optional] Specify the name of the Edges table column that contains the edge weights. The function uses only positive edge weights. The sum of the edge weights that the function uses must be 1.</dd><dd class="dd pd ddexpand">Default behavior: All edges have equal weight.</dd><dt class="dt pt dlterm">Accumulate</dt><dd class="dd pd">[Optional] Specify the names of the Vertices table columns to copy to the output table.</dd><dt class="dt pt dlterm">MaxIterNum</dt><dd class="dd pd">[Optional] Specify the maximum number of iterations that the algorithm can run.</dd><dd class="dd pd ddexpand">Default: 20</dd><dt class="dt pt dlterm">StopThreshold</dt><dd class="dd pd">[Optional] Specify the threshold value for convergence.</dd><dd class="dd pd ddexpand">Default: 0.0001</dd></dl></div></div></div></div></body></html>
