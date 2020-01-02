<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="vzk1572296570258" id="vzk1572296570258"><h1 class="title topictitle1" id="ariaid-title1">GLMPerSegment</h1><div class="body conbody">
<p class="p">GLMPerSegment takes a single, partitioned input table and creates a model for each partition.</p>
<p class="p">Use case example: A retailer has a table of product sales characteristics that varies by zip code, and wants to build separate models that use only data specific to a product and a region.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="hfw1572296589234" xml:lang="en-us" lang="en-us" id="hfw1572296589234">
<h2 class="title topictitle2" id="ariaid-title2">GLMPerSegment Syntax</h2><div class="body refbody"><div class="section" id="hfw1572296589234__section_N10087_N10022_N10001">
<h3 class="title sectiontitle">Version TBD</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM GLMPerSegment (
    <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span>
      PARTITION BY { <var class="keyword varname">partition_column</var> [, ...] | 1 }
    [ <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS AttributeTable
      PARTITION BY { <var class="keyword varname">partition_column</var> [, ...] | 1 } ]
    [ <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS ParameterTable
      PARTITION BY { <var class="keyword varname">partition_column</var> [, ...] | 1 } ]
    USING
    TargetColumns ( { '<var class="keyword varname">target_column</var>' | <var class="keyword varname">target_column_range</var> } [,...] )
    [ CategoricalColumns ( '<var class="keyword varname">categorical_column</var>' [,...] ) ]
    ResponseColumn ('<var class="keyword varname">input_column</var>')
    [ Family ( { 'BINOMIAL' | 'GAUSSIAN' } ) ]
    [ Alpha ('<var class="keyword varname">alpha</var>') ]
    [ RegularizationLambda ('<var class="keyword varname">lambda</var>') ]
    [ StopThreshold ('<var class="keyword varname">threshold</var>') ]
    [ MaxIterNum ('<var class="keyword varname">max_iterations</var>') ]
    [ FeatureScale ( <span><b>{'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}</b></span> ) ]
    [ CategoricalEncoding ( { 'Onehot' | 'Target' } ) ]
    [ MinSamplesForEncoding (<var class="keyword varname">k</var>) ]
    [ Smoothing (<var class="keyword varname">f</var>) ]
    [ ErrorHandler ( <span><b>{'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}</b></span> ) ]
);
</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist"><div class="linklistmember"><a href="eta1543514041091.md">Comments in Queries</a></div><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="omk1572296611775" xml:lang="en-us" lang="en-us" id="omk1572296611775">
<h2 class="title topictitle2" id="ariaid-title3">GLMPerSegment Syntax Elements</h2><div class="body refbody"><div class="section" id="omk1572296611775__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">TargetColumns</dt><dd class="dd pd">Specify the names of the input table columns that contain the variables to use as predictors (independent variables) in the models.</dd><dd class="dd pd ddexpand">Every <var class="keyword varname">target_column</var> is numerical unless you specify it with CategoricalColumns.</dd><dt class="dt pt dlterm">CategoricalColumns</dt><dd class="dd pd">[Optional] Specify the names of the input table columns to treat as categorical variables.</dd><dd class="dd pd ddexpand">For information about columns that you must identify as numeric or categorical, see <a href="uxa1540574678350.md">Identification of Numeric and Categorical Columns</a>.</dd><dt class="dt pt dlterm">ResponseColumn</dt><dd class="dd pd">Specify the name of the input table column that contains the responses.</dd><dt class="dt pt dlterm">Family</dt><dd class="dd pd">[Optional] Specify the distribution exponential family.</dd><dd class="dd pd ddexpand">Default: 'GAUSSIAN'</dd><dt class="dt pt dlterm">Alpha</dt><dd class="dd pd">[Optional] Specify the mixing parameter for penalty computation (see the following table). The <var class="keyword varname">alpha</var> must be in [0, 1]. If <var class="keyword varname">alpha</var> is in (0,1), it represents α in the elastic net regularization formula in <a href="kwd1540576635575.md">Generalized Linear Model (GLM) Functions (ML Engine)</a>.
<div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="omk1572296611775__table_bdv_f35_lz" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:20%" span="1"></col><col style="width:20%" span="1"></col><col style="width:60%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e253" rowspan="1" colspan="1"><var class="keyword varname">alpha</var></th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e256" rowspan="1" colspan="1">Regularization Type</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e258" rowspan="1" colspan="1">Parameter Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e253" rowspan="1" colspan="1">0</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e256" rowspan="1" colspan="1">Ridge</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e258" rowspan="1" colspan="1"><img class="image" id="omk1572296611775__image_trx_kkp_4z" src="hjg1527875586223.png" alt="Formula for ridge regularization, used by Machine Learning Engine function GLML1L2"></img></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e253" rowspan="1" colspan="1">(0,1)</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e256" rowspan="1" colspan="1">Elastic net</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e258" rowspan="1" colspan="1"><img class="image" id="omk1572296611775__image_s1s_xxc_12b" src="lcy1527880270334.png" alt="Formula for elastic net regularization, used by Machine Learning Engine function GLML1L2"></img></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e253" rowspan="1" colspan="1">1</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e256" rowspan="1" colspan="1">LASSO</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e258" rowspan="1" colspan="1"><img class="image" id="omk1572296611775__image_dzl_hlp_4z" src="cuy1527878530860.png" alt="Formula for LASSO regularization, used by Machine Learning Engine function GLML1L2"></img></td></tr></tbody></table></div></dd><dd class="dd pd ddexpand">Default: 0</dd><dt class="dt pt dlterm">RegularizationLambda</dt><dd class="dd pd">[Optional] Specify the parameter that controls the magnitude of the regularization term. The value <var class="keyword varname">lambda</var> must be in the range [0, 100]. The value 0 disables regularization.<div class="note note" id="omk1572296611775__note_N10118_N1010F_N10108_N10018_N10014_N10010_N10001"><span><b>Note</b></span><div class="notebody">The function also accepts the syntax element name Lambda, which was the name of RegularizationLambda in the GLML1L2 function before release MLE 8.10. See <a href="nzr1568145542450.md">Argument Name Changes for Vantage 1.1 and Above</a>.</div></div></dd><dd class="dd pd ddexpand">Default: 0</dd><dt class="dt pt dlterm">StopThreshold</dt><dd class="dd pd">[Optional] Specify the convergence threshold. The <var class="keyword varname">threshold</var> must be a nonnegative DOUBLE PRECISION value.</dd><dd class="dd pd ddexpand">Default: 1.0e<span><sup>-7</sup></span></dd><dt class="dt pt dlterm">MaxIterNum</dt><dd class="dd pd">[Optional] Specify the maximum number of iterations over the data. The parameter <var class="keyword varname">max_iterations</var> must be a positive INTEGER value in the range [1, 100000].</dd><dd class="dd pd ddexpand">Default: 10000</dd><dt class="dt pt dlterm">FeatureScale</dt><dd class="dd pd">[Optional] Specify whether to scale numeric target columns to the range [-1, 1].</dd><dd class="dd pd ddexpand">Default: 'false' (no scaling)</dd><dt class="dt pt dlterm">CategoricalEncoding</dt><dd class="dd pd">[Optional with CategoricalColumns, disallowed otherwise.] Specify the encoding scheme to use for categorical variables.
<div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="omk1572296611775__table_N1016D_N10169_N10162_N10018_N10014_N10010_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:50%" span="1"></col><col style="width:50%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e358" rowspan="1" colspan="1">Option</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e360" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e358" rowspan="1" colspan="1">'Onehot'</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e360" rowspan="1" colspan="1">Expands each category under corresponding column into new column.
<p class="p">For example, if column Programming has categories a, b, and c, function replaces column Programming with columns Programming_a and Programming_b and drops Programming_c.</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e358" rowspan="1" colspan="1">'Target'</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e360" rowspan="1" colspan="1">Uses target encoding described in <cite class="cite">A Preprocessing Scheme for High-Cardinality Categorical Attributes in Classification and Prediction Problems</cite>(<a class="xref" href="https://www.researchgate.net/publication/220520258" target="_blank" title="" shape="rect">https://www.researchgate.net/publication/220520258</a>).</td></tr></tbody></table></div></dd><dd class="dd pd ddexpand">Default: 'Onehot'</dd><dt class="dt pt dlterm">MinSamplesForEncoding</dt><dd class="dd pd">[Optional with CategoricalEncoding ('Target'), disallowed otherwise.] Specify minimum number of samples for target encoding, which is <var class="keyword varname">k</var> in the following formula:</dd><dd class="dd pd ddexpand">Ɣ (<var class="keyword varname">n</var>) = 1 / (1 + <var class="keyword varname">e</var><span><sup>-( (<var class="keyword varname">n</var> - <var class="keyword varname">k</var>)/<var class="keyword varname">f</var>)</sup></span>)</dd><dd class="dd pd ddexpand">The Target encoding algorithm uses the hyperparameter Ɣ.</dd><dd class="dd pd ddexpand">MinSamplesForEncoding is the same as the min_samples_leaf parameter in <a class="xref" href="https://contrib.scikit-learn.org/categorical-encoding/targetencoder.html" target="_blank" title="" shape="rect">https://contrib.scikit-learn.org/categorical-encoding/targetencoder.html</a>.</dd><dd class="dd pd ddexpand">Default: 1.0</dd><dt class="dt pt dlterm">Smoothing</dt><dd class="dd pd">[Optional with CategoricalEncoding ('Target'), disallowed otherwise.] Specify smoothing parameter for target encoding, which is <var class="keyword varname">f</var> in the following formula:</dd><dd class="dd pd ddexpand">Ɣ (<var class="keyword varname">n</var>) = 1 / (1 + <var class="keyword varname">e</var><span><sup>-( (<var class="keyword varname">n</var> - <var class="keyword varname">k</var>)/<var class="keyword varname">f</var>)</sup></span>)</dd><dd class="dd pd ddexpand">The Target encoding algorithm uses the hyperparameter Ɣ.</dd><dd class="dd pd ddexpand">Smoothing is the same as the smoothing parameter in <a class="xref" href="https://contrib.scikit-learn.org/categorical-encoding/targetencoder.html" target="_blank" title="" shape="rect">https://contrib.scikit-learn.org/categorical-encoding/targetencoder.html</a>.</dd><dd class="dd pd ddexpand">Default: 1.0</dd><dt class="dt pt dlterm">ErrorHandler</dt><dd class="dd pd">[Optional] Specify whether, when the function finds an error, it continues with the next model:
<div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="omk1572296611775__table_N1016B_N10168_N10163_N10018_N10014_N10010_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:50%" span="1"></col><col style="width:50%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e470" rowspan="1" colspan="1">Value</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e472" rowspan="1" colspan="1">Function Behavior</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e470" rowspan="1" colspan="1">'true'</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e472" rowspan="1" colspan="1">Function skips partition where error occurs and continues with next partition. Output table displays error message.</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e470" rowspan="1" colspan="1">'false'</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e472" rowspan="1" colspan="1">Function stops and reports error.</td></tr></tbody></table></div></dd><dd class="dd pd ddexpand">Default: 'false'</dd></dl></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title4" topicindex="4" topicid="ewd1572296631597" xml:lang="en-us" lang="en-us" id="ewd1572296631597">
<h2 class="title topictitle2" id="ariaid-title4">GLMPerSegment Input</h2><div class="body refbody"><div class="section" id="ewd1572296631597__section_N1000E_N1000C_N10001"><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="ewd1572296631597__table_cqq_dqv_xcb" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:50%" span="1"></col><col style="width:50%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e506" rowspan="1" colspan="1">Table</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e508" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e506" rowspan="1" colspan="1">InputTable</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e508" rowspan="1" colspan="1">Contains data sets to use to build models. Function builds one model for each partition.</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e506" rowspan="1" colspan="1">AttributeTable</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e508" rowspan="1" colspan="1">[Optional] Contains predictors to use for specified partitions.
<p class="p">If any input table partition key (which may have one or more columns) is not in AttributeTable, function uses all input table attributes specified by TargetColumns for that partition to build the model.</p>
<p class="p">If you omit AttributeTable, function uses every specified target column (every <var class="keyword varname">numeric_input_column</var> and <var class="keyword varname">categorical_input_column</var>) in every model.</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e506" rowspan="1" colspan="1">ParameterTable</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e508" rowspan="1" colspan="1">[Optional] Contains parameter values to use for specified partitions.
<p class="p">If any input table partition key (which may have one or more columns) is not in ParameterTable, function uses parameter values specified by syntax elements to build the model.</p>
<p class="p">If you omit ParameterTable, function uses parameter values specified by syntax elements for every partition.</p></td></tr></tbody></table></div></div><div class="section" id="ewd1572296631597__section_s4l_brv_xcb">
<h3 class="title sectiontitle">InputTable Schema</h3><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="ewd1572296631597__table_N10021_N10019_N10014_N1000E_N1000C_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:28.57142857142857%" span="1"></col><col style="width:14.285714285714285%" span="1"></col><col style="width:57.14285714285714%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry nocellnorowborder" style="vertical-align:top;" id="d106909e550" rowspan="1" colspan="1">Column</th><th class="entry nocellnorowborder" style="vertical-align:top;" id="d106909e552" rowspan="1" colspan="1">Data Type</th><th class="entry cell-norowborder" style="vertical-align:top;" id="d106909e554" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e550" rowspan="1" colspan="1"><var class="keyword varname">partition_column</var></td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e552" rowspan="1" colspan="1">Any</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e554" rowspan="1" colspan="1">[Column appears once for each specified <var class="keyword varname">partition_column</var>.] Column by which input table is partitioned. Function creates one model for each partiton.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e550" rowspan="1" colspan="1"><var class="keyword varname">response_column</var></td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e552" rowspan="1" colspan="1"><span>Any numeric SQL data type</span></td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e554" rowspan="1" colspan="1">Dependent/response variable. If column contains NULL, function ignores row.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e550" rowspan="1" colspan="1"><var class="keyword varname">numeric_column</var></td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e552" rowspan="1" colspan="1"><span>Any numeric SQL data type</span></td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e554" rowspan="1" colspan="1">[Column appears one or more times.] Independent/predictor variable. If column contains NULL, function ignores row.</td></tr><tr class="row"><td class="entry row-nocellborder" style="vertical-align:top;" headers="d106909e550" rowspan="1" colspan="1"><var class="keyword varname">categorical_column</var></td><td class="entry row-nocellborder" style="vertical-align:top;" headers="d106909e552" rowspan="1" colspan="1">Any</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e554" rowspan="1" colspan="1">[Column appears once for each <var class="keyword varname">categorical_column</var>.] Categorical independent/predictor variable. If column contains NULL, function ignores row.</td></tr></tbody></table></div></div><div class="section" id="ewd1572296631597__section_N10107_N1000E_N10001">
<h3 class="title sectiontitle">AttributeTable Schema</h3><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="ewd1572296631597__table_N1010E_N10107_N1000E_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:33.33333333333333%" span="1"></col><col style="width:33.33333333333333%" span="1"></col><col style="width:33.33333333333333%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e607" rowspan="1" colspan="1">Column</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e609" rowspan="1" colspan="1">Data Type</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e611" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e607" rowspan="1" colspan="1"><var class="keyword varname">partition_column</var></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e609" rowspan="1" colspan="1">Any</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e611" rowspan="1" colspan="1">[Column appears once for each specified <var class="keyword varname">partition_column</var>.] Column on which to partition table.
<p class="p">You must specify this column in PARTITION BY clause of input table.</p>
<p class="p">Partition columns must start in first colum, be contiguous, and appear before <var class="keyword varname">attribute_column</var> and <var class="keyword varname">value_column</var> in the table.</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e607" rowspan="1" colspan="1"><var class="keyword varname">attribute_column</var></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e609" rowspan="1" colspan="1">VARCHAR</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e611" rowspan="1" colspan="1">Contains names of target columns in input table.
<p class="p">If this column contains duplicate values, the function displays an error message.</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e607" rowspan="1" colspan="1"><var class="keyword varname">value_column</var></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e609" rowspan="1" colspan="1">INTEGER</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e611" rowspan="1" colspan="1">1 for numeric attribute, 0 for categorical attribute.</td></tr></tbody></table></div></div><div class="section" id="ewd1572296631597__section_N10164_N1000E_N10001">
<h3 class="title sectiontitle">ParameterTable Schema</h3><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="ewd1572296631597__table_N1016C_N10165_N1000E_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:33.33333333333333%" span="1"></col><col style="width:33.33333333333333%" span="1"></col><col style="width:33.33333333333333%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e663" rowspan="1" colspan="1">Column</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e665" rowspan="1" colspan="1">Data Type</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e667" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e663" rowspan="1" colspan="1"><var class="keyword varname">partition_column</var></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e665" rowspan="1" colspan="1">Any</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e667" rowspan="1" colspan="1">[Column appears once for each specified <var class="keyword varname">partition_column</var>.] Column on which to partition table.
<p class="p">Partition columns must start in first colum, be contiguous, and appear before <var class="keyword varname">parameter_column</var> and <var class="keyword varname">value_column</var> in the table.</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e663" rowspan="1" colspan="1"><var class="keyword varname">parameter_column</var></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e665" rowspan="1" colspan="1">VARCHAR</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e667" rowspan="1" colspan="1">One of the following syntax elements:
<ul class="ul">
<li class="li">Family</li>
<li class="li">Alpha</li>
<li class="li">RegularizationLambda (or Lambda)</li>
<li class="li">StopThreshold</li>
<li class="li">MaxIterNum</li>
<li class="li">FeatureScale</li>
<li class="li">CategoricalEncoding</li>
<li class="li">MinSamplesForEncoding</li>
<li class="li">Smoothing</li></ul>
<p class="p">If this column contains duplicate values, the function displays an error message.</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e663" rowspan="1" colspan="1"><var class="keyword varname">value_column</var></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e665" rowspan="1" colspan="1">VARCHAR</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e667" rowspan="1" colspan="1">Value to use for syntax element for partition.</td></tr></tbody></table></div></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title5" topicindex="5" topicid="xag1572296661289" xml:lang="en-us" lang="en-us" id="xag1572296661289">
<h2 class="title topictitle2" id="ariaid-title5">GLMPerSegment Output</h2><div class="body refbody"><div class="section" id="xag1572296661289__section_mnp_djv_xcb">
<h3 class="title sectiontitle">Output Table Schema</h3><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="xag1572296661289__table_N1000E_N1000C_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:28.57142857142857%" span="1"></col><col style="width:14.285714285714285%" span="1"></col><col style="width:57.14285714285714%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry nocellnorowborder" style="vertical-align:top;" id="d106909e745" rowspan="1" colspan="1">Column</th><th class="entry nocellnorowborder" style="vertical-align:top;" id="d106909e747" rowspan="1" colspan="1">Data Type</th><th class="entry cell-norowborder" style="vertical-align:top;" id="d106909e749" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e745" rowspan="1" colspan="1"><var class="keyword varname">partition_column</var></td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e747" rowspan="1" colspan="1"><span>Same as in input table</span></td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e749" rowspan="1" colspan="1">[Column appears only if input table has PARTITION BY clause.]</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e745" rowspan="1" colspan="1">attribute</td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e747" rowspan="1" colspan="1">VARCHAR</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e749" rowspan="1" colspan="1">Model attribute name.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e745" rowspan="1" colspan="1">category</td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e747" rowspan="1" colspan="1">VARCHAR</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e749" rowspan="1" colspan="1">[Column appears only for categorical predictor.] Category (level) of predictor.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e745" rowspan="1" colspan="1">estimate</td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e747" rowspan="1" colspan="1">DOUBLE PRECISION</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e749" rowspan="1" colspan="1">Estimate of model coefficient.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e745" rowspan="1" colspan="1">mean</td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e747" rowspan="1" colspan="1">DOUBLE PRECISION</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e749" rowspan="1" colspan="1">Depends on FeatureScale value and predictor type:<div class="p"><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="xag1572296661289__table_N100A8_N100A6_N100A2_N10098_N10045_N1001D_N10019_N10011_N1000E_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:50%" span="1"></col><col style="width:50%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e796" rowspan="1" colspan="1">FeatureScale Value</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e798" rowspan="1" colspan="1">Column Value</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e796" rowspan="1" colspan="1">'true'</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e798" rowspan="1" colspan="1">Mean value, after scaling, of input table attribute</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e796" rowspan="1" colspan="1">'false'</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e798" rowspan="1" colspan="1">NULL</td></tr></tbody></table></div></div></td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e745" rowspan="1" colspan="1">std</td><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d106909e747" rowspan="1" colspan="1">DOUBLE PRECISION</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d106909e749" rowspan="1" colspan="1">Depends on FeatureScale value and predictor type:<div class="p"><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="xag1572296661289__table_N100FE_N100FC_N100F8_N100EE_N10045_N1001D_N10019_N10011_N1000E_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:50%" span="1"></col><col style="width:50%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e825" rowspan="1" colspan="1">FeatureScale Value</th><th class="entry cellrowborder" style="vertical-align:top;" id="d106909e827" rowspan="1" colspan="1">Column Value</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e825" rowspan="1" colspan="1">'true'</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e827" rowspan="1" colspan="1">Standard deviation, after scaling, of input table attribute</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e825" rowspan="1" colspan="1">'false'</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e827" rowspan="1" colspan="1">NULL</td></tr></tbody></table></div></div></td></tr><tr class="row"><td class="entry row-nocellborder" style="vertical-align:top;" headers="d106909e745" rowspan="1" colspan="1">information</td><td class="entry row-nocellborder" style="vertical-align:top;" headers="d106909e747" rowspan="1" colspan="1">VARCHAR</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d106909e749" rowspan="1" colspan="1">Value of categorical attribute, followed by "p" if model uses predictor.</td></tr></tbody></table></div></div></div></div><div class="topic concept nested1" aria-labelledby="ariaid-title6" topicindex="6" topicid="jjb1572296677076" xml:lang="en-us" lang="en-us" id="jjb1572296677076">
<h2 class="title topictitle2" id="ariaid-title6">GLMPerSegment Examples</h2><div class="topic reference nested2" aria-labelledby="ariaid-title7" topicindex="7" topicid="gmz1572296697203" xml:lang="en-us" lang="en-us" id="gmz1572296697203">
<h3 class="title topictitle3" id="ariaid-title7">GLMPerSegment Example: Regression, Family ('GAUSSIAN')</h3><div class="body refbody"><div class="section" id="gmz1572296697203__section_N10011_N1000E_N10001">
<h4 class="title sectiontitle">Input</h4>
<ul class="ul">
<li class="li">housing_train, as in <a href="adk1542222001867.md">DecisionForest Example: TreeType ('classification'), OutOfBag ('false')</a>
<p class="p">The table has data for three different homestyles—eclectic, classic, and bungalow.</p></li></ul></div><div class="section" id="gmz1572296697203__section_qhy_1kz_m2b">
<h4 class="title sectiontitle">SQL Call</h4>
<p class="p">Because the PARTITION BY clause separates the data by homestyle, the function creates three different models, one for each homestyle.</p><pre class="pre codeblock" xml:space="preserve"><code>CREATE MULTISET TABLE glm_ps_housing_1 AS (
  SELECT * FROM GlmPerSegment (
    ON housing_train <span>PARTITION BY homestyle</span>
    USING
    TargetColumns ('lotsize','bedrooms','bathrms','stories',
      'garagepl','driveway','recroom','fullbase','gashw','airco','prefarea')
    CategoricalColumns ('driveway','recroom','fullbase',
      'gashw','airco','prefarea')
    ResponseColumn ('price')
    Family ('GAUSSIAN') 
    FeatureScale ('True')
  ) AS dt
) WITH DATA;
</code></pre></div><div class="section" id="gmz1572296697203__section_spg_ckz_m2b">
<h4 class="title sectiontitle">Output</h4>
<p class="p">The output table shows the model coefficients. The first column identifies the model.</p>
<p class="p">Because the SQL call includes FeatureScale ('True'), the output table has mean and std (standard deviation) columns with a value for each numeric predictor. When you use this output table as input to the GLMPredictPerSegment function, that GLMPredictPerSegment uses these mean and std values to scale the corresponding predictor values in its input table.</p><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM glm_ps_housing_1 ORDER BY homestyle, attribute;</code></pre><pre class="pre screen" xml:space="preserve">homestyle attribute       category estimate            mean                std                 information 
 --------- --------------- -------- ------------------- ------------------- ------------------- ----------- 
 bungalow  (Intercept)     NULL      115591.93275042695                NULL                NULL p          
 bungalow  AIC             NULL     -16.324158095527835                NULL                NULL NULL       
 bungalow  BIC             NULL       5.954710502558811                NULL                NULL NULL       
 bungalow  Converged       NULL                    NULL                NULL                NULL true       
 bungalow  Encoder         NULL                    NULL                NULL                NULL Onehot     
 bungalow  Family          NULL                    NULL                NULL                NULL Gaussian   
 bungalow  Feature scaling NULL                    NULL                NULL                NULL true       
 bungalow  Features #      NULL                    11.0                NULL                NULL NULL       
 bungalow  Iterations #    NULL                    31.0                NULL                NULL NULL       
 bungalow  RMSE            NULL      14487.471549967298                NULL                NULL NULL       
 bungalow  Rows #          NULL                    56.0                NULL                NULL NULL       
 bungalow  airco           no                      NULL                NULL                NULL p          
 bungalow  airco           yes        3641.206423256279                NULL                NULL p          
 bungalow  bathrms         NULL        6534.69327194008               1.875  0.3950892857142856 p          
 bungalow  bedrooms        NULL       911.6086146259966  3.4464285714285716 0.38998724489795755 p          
 bungalow  driveway        yes                     NULL                NULL                NULL p          
 bungalow  fullbase        no                      NULL                NULL                NULL p          
 bungalow  fullbase        yes        9285.856289616007                NULL                NULL p          
 bungalow  garagepl        NULL       8870.885275591605  1.3571428571428572   0.551020408163265 p          
 bungalow  gashw           no                      NULL                NULL                NULL p          
 bungalow  gashw           yes       -4201.769201096887                NULL                NULL p          
 bungalow  lotsize         NULL       4940.859632235966   7173.071428571428    4053903.85204082 p          
 bungalow  prefarea        yes        6114.951846858752                NULL                NULL p          
 bungalow  prefarea        no                      NULL                NULL                NULL p          
 bungalow  recroom         yes       -4614.142473137047                NULL                NULL p          
 bungalow  recroom         no                      NULL                NULL                NULL p          
 bungalow  stories         NULL     -3101.8862212544286  2.6607142857142856  1.1527423469387763 p          
 classic   (Intercept)     NULL       40907.22587994486                NULL                NULL p          
 classic   AIC             NULL     -10.910877222170988                NULL                NULL NULL       
 classic   BIC             NULL      24.388831849140658                NULL                NULL NULL       
 classic   Converged       NULL                    NULL                NULL                NULL true       
 classic   Encoder         NULL                    NULL                NULL                NULL Onehot     
 classic   Family          NULL                    NULL                NULL                NULL Gaussian   
 classic   Feature scaling NULL                    NULL                NULL                NULL true       
 classic   Features #      NULL                    12.0                NULL                NULL NULL       
 classic   Iterations #    NULL                    61.0                NULL                NULL NULL       
 classic   RMSE            NULL       6171.636430901101                NULL                NULL NULL       
 classic   Rows #          NULL                   140.0                NULL                NULL NULL       
 classic   airco           yes        3275.190890476861                NULL                NULL p          
 classic   airco           no                      NULL                NULL                NULL p          
 classic   bathrms         NULL      -42.96823593630901                1.05 0.06178571428571433 p          
 classic   bedrooms        NULL      140.60232050248226  2.6857142857142855  0.5583673469387769 p          
 classic   driveway        no                      NULL                NULL                NULL p          
 classic   driveway        yes        662.7139738807844                NULL                NULL p          
 classic   fullbase        no                      NULL                NULL                NULL p          
 classic   fullbase        yes        2343.534370609944                NULL                NULL p          
 classic   garagepl        NULL       952.6951533853348 0.32142857142857145  0.3466836734693878 p          
 classic   gashw           no                      NULL                NULL                NULL p          
 classic   gashw           yes      -2847.8794321572254                NULL                NULL p          
 classic   lotsize         NULL      1475.6249866354628  3959.3142857142857   2569760.572653061 p          
 classic   prefarea        no                      NULL                NULL                NULL p          
 classic   prefarea        yes       3746.1874108332136                NULL                NULL p          
 classic   recroom         yes      -1239.0217663461603                NULL                NULL p          
 classic   recroom         no                      NULL                NULL                NULL p          
 classic   stories         NULL       584.3076309876135  1.4785714285714286  0.3066836734693874 p          
 eclectic  (Intercept)     NULL       58214.69870085926                NULL                NULL p          
 eclectic  AIC             NULL     -12.594030498298252                NULL                NULL NULL       
 eclectic  BIC             NULL       31.69028295359047                NULL                NULL NULL       
 eclectic  Converged       NULL                    NULL                NULL                NULL true       
 eclectic  Encoder         NULL                    NULL                NULL                NULL Onehot     
 eclectic  Family          NULL                    NULL                NULL                NULL Gaussian   
 eclectic  Feature scaling NULL                    NULL                NULL                NULL true       
 eclectic  Features #      NULL                    12.0                NULL                NULL NULL       
 eclectic  Iterations #    NULL                    39.0                NULL                NULL NULL       
 eclectic  RMSE            NULL        9400.40097792685                NULL                NULL NULL       
 eclectic  Rows #          NULL                   296.0                NULL                NULL NULL       
 eclectic  airco           yes        6849.331667063833                NULL                NULL p          
 eclectic  airco           no                      NULL                NULL                NULL p          
 eclectic  bathrms         NULL       3063.052474753343  1.2972972972972974 0.23593864134404652 p          
 eclectic  bedrooms        NULL      460.31347283555937  3.0067567567567566  0.4661705624543462 p          
 eclectic  driveway        yes        6025.710420749092                NULL                NULL p          
 eclectic  driveway        no                      NULL                NULL                NULL p          
 eclectic  fullbase        yes       2960.1041876659283                NULL                NULL p          
 eclectic  fullbase        no                      NULL                NULL                NULL p          
 eclectic  garagepl        NULL       447.2485222817308  0.7297297297297297     0.7918188458729 p          
 eclectic  gashw           yes        6084.074339051068                NULL                NULL p          
 eclectic  gashw           no                      NULL                NULL                NULL p          
 eclectic  lotsize         NULL       4623.354755447712   5383.266891891892    4420903.20241737 p          
 eclectic  prefarea        yes       6213.6409412039975                NULL                NULL p          
 eclectic  prefarea        no                      NULL                NULL                NULL p          
 eclectic  recroom         yes        3214.444013806346                NULL                NULL p          
 eclectic  recroom         no                      NULL                NULL                NULL p          
 eclectic  stories         NULL      3601.3734927957944  1.7939189189189189  0.6771251826150477 p       
</pre></div><div class="section" id="gmz1572296697203__section_N10644_N10023_N10001">
<p class="p">Download a zip file of all examples and a SQL script file that creates their input tables from the attachment in the left sidebar.</p></div></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title8" topicindex="8" topicid="btn1572296714020" xml:lang="en-us" lang="en-us" id="btn1572296714020">
<h3 class="title topictitle3" id="ariaid-title8">GLMPerSegment Example: Regression, AttributeTable, ParameterTable</h3><div class="body refbody"><div class="section" id="btn1572296714020__section_N10027_N10024_N10001">
<p class="p">This example is like <a href="vzk1572296570258.md#gmz1572296697203">GLMPerSegment Example: Regression, Family ('GAUSSIAN')</a>, except that the SQL call specifies AttributeTable and ParameterTable. When the function creates a model for each partition, it uses the attributes and parameters that AttributeTable and ParameterTable specify for that partition.</p></div><div class="section" id="btn1572296714020__section_N10018_N1000E_N10001">
<h4 class="title sectiontitle">Input</h4>
<p class="p">All input tables are partitioned by homestyle.</p>
<ul class="ul">
<li class="li">housing_train, as in <a href="adk1542222001867.md">DecisionForest Example: TreeType ('classification'), OutOfBag ('false')</a>
<p class="p">This table has data from three different homestyles—eclectic, classic, and bungalow.</p></li>
<li class="li">AttributeTable: att_table<pre class="pre screen" xml:space="preserve">homestyle attribute_col value_col 
--------- ------------- --------- 
eclectic  airco                 0
eclectic  driveway              0
eclectic  fullbase              0
eclectic  gashw                 0
eclectic  prefarea              0
eclectic  recroom               0
classic   bathrms               1
classic   bedrooms              1
classic   garagepl              1
classic   lotsize               1
bungalow  bathrms               1
bungalow  bedrooms              1
bungalow  fullbase              0
bungalow  recroom               0
</pre></li>
<li class="li">ParameterTable: param_table<pre class="pre screen" xml:space="preserve">homestyle param_col value_col 
--------- --------- --------- 
eclectic  Alpha           0.5
eclectic  Lambda          0.2
classic   Alpha           0.3
classic   Lambda          1.0
bungalow  Alpha           0.1
bungalow  Lambda         10.0
</pre></li></ul></div><div class="section" id="btn1572296714020__section_ljr_jqc_4db">
<h4 class="title sectiontitle">SQL Call</h4><pre class="pre codeblock" xml:space="preserve"><code>CREATE MULTISET TABLE glm_ps_housing_2 AS (
  SELECT * FROM GlmPerSegment (
    ON housing_train PARTITION BY homestyle
    <span>ON att_table AS AttributeTable PARTITION BY homestyle</span>
    <span>ON param_table AS ParameterTable PARTITION BY homestyle</span>
    USING
    TargetColumns ('lotsize','bedrooms','bathrms','stories',
      'garagepl','driveway','recroom','fullbase','gashw','airco','prefarea')
    CategoricalColumns ('driveway','recroom','fullbase',
      'gashw','airco','prefarea')
    ResponseColumn ('price')
    Family ('GAUSSIAN') 
    FeatureScale ('True')
  ) AS dt
) WITH DATA;
</code></pre></div><div class="section" id="btn1572296714020__section_i4h_kqc_4db">
<h4 class="title sectiontitle">Output</h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM glm_ps_housing_2 ORDER BY homestyle, attribute;</code></pre><pre class="pre screen" xml:space="preserve">homestyle attribute       category estimate            mean               std                 information 
--------- --------------- -------- ------------------- ------------------ ------------------- ----------- 
bungalow  (Intercept)     NULL       19604.46964245121               NULL                NULL p          
bungalow  AIC             NULL      -36.48391719423681               NULL                NULL NULL       
bungalow  Alpha           NULL                     0.0               NULL                NULL NULL       
bungalow  BIC             NULL      -26.35715874056106               NULL                NULL NULL       
bungalow  Converged       NULL                    NULL               NULL                NULL true       
bungalow  Encoder         NULL                    NULL               NULL                NULL Onehot     
bungalow  Family          NULL                    NULL               NULL                NULL Gaussian   
bungalow  Feature scaling NULL                    NULL               NULL                NULL true       
bungalow  Features #      NULL                     5.0               NULL                NULL NULL       
bungalow  Iterations #    NULL                    33.0               NULL                NULL NULL       
bungalow  Lambda          NULL                    10.0               NULL                NULL NULL       
bungalow  RMSE            NULL      111410.77201892057               NULL                NULL NULL       
bungalow  Regularization  NULL                    NULL               NULL                NULL Ridge      
bungalow  Rows #          NULL                    56.0               NULL                NULL NULL       
bungalow  bathrms         NULL      1191.6320528175604              1.875  0.3950892857142856 p          
bungalow  bedrooms        NULL       624.8710884149968 3.4464285714285716 0.38998724489795755 p          
bungalow  fullbase        yes        7445.193131141103               NULL                NULL p          
bungalow  fullbase        no                      NULL               NULL                NULL p          
bungalow  recroom         yes        5989.427728775645               NULL                NULL p          
bungalow  recroom         no                      NULL               NULL                NULL p          
classic   (Intercept)     NULL      28122.833342816513               NULL                NULL p          
classic   AIC             NULL     -36.544810991344995               NULL                NULL NULL       
classic   Alpha           NULL                     0.0               NULL                NULL NULL       
classic   BIC             NULL     -30.661526146126388               NULL                NULL NULL       
classic   Converged       NULL                    NULL               NULL                NULL true       
classic   Family          NULL                    NULL               NULL                NULL Gaussian   
classic   Feature scaling NULL                    NULL               NULL                NULL true       
classic   Features #      NULL                     2.0               NULL                NULL NULL       
classic   Iterations #    NULL                    14.0               NULL                NULL NULL       
classic   Lambda          NULL                     1.0               NULL                NULL NULL       
classic   RMSE            NULL      25240.439966845504               NULL                NULL NULL       
classic   Regularization  NULL                    NULL               NULL                NULL Ridge      
classic   Rows #          NULL                   140.0               NULL                NULL NULL       
classic   lotsize         NULL      1026.2521682058573 3959.3142857142857   2569760.572653061 p          
eclectic  (Intercept)     NULL       56080.36485181545               NULL                NULL p          
eclectic  AIC             NULL      -23.41259036697003               NULL                NULL NULL       
eclectic  BIC             NULL      2.4199258132983914               NULL                NULL NULL       
eclectic  Converged       NULL                    NULL               NULL                NULL true       
eclectic  Encoder         NULL                    NULL               NULL                NULL Onehot     
eclectic  Family          NULL                    NULL               NULL                NULL Gaussian   
eclectic  Feature scaling NULL                    NULL               NULL                NULL true       
eclectic  Features #      NULL                     7.0               NULL                NULL NULL       
eclectic  Iterations #    NULL                    37.0               NULL                NULL NULL       
eclectic  RMSE            NULL       11535.07406802602               NULL                NULL NULL       
eclectic  Rows #          NULL                   296.0               NULL                NULL NULL       
eclectic  airco           no                      NULL               NULL                NULL p          
eclectic  airco           yes        9295.933335092257               NULL                NULL p          
eclectic  driveway        yes        7761.735941401268               NULL                NULL p          
eclectic  driveway        no                      NULL               NULL                NULL p          
eclectic  fullbase        no                      NULL               NULL                NULL p          
eclectic  fullbase        yes        765.7950945103938               NULL                NULL p          
eclectic  gashw           no                      NULL               NULL                NULL p          
eclectic  gashw           yes        6908.006217537264               NULL                NULL p          
eclectic  prefarea        no                      NULL               NULL                NULL p          
eclectic  prefarea        yes        7409.458973650767               NULL                NULL p          
eclectic  recroom         no                      NULL               NULL                NULL p          
eclectic  recroom         yes        4687.416335955312               NULL                NULL p</pre></div><div class="section" id="btn1572296714020__section_N10491_N10023_N10001">
<p class="p">Download a zip file of all examples and a SQL script file that creates their input tables from the attachment in the left sidebar.</p></div></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title9" topicindex="9" topicid="otd1572896246305" xml:lang="en-us" lang="en-us" id="otd1572896246305">
<h3 class="title topictitle3" id="ariaid-title9">GLMPerSegment Example: Logical Regression, Family ('BINOMIAL')</h3><div class="body refbody"><div class="section" id="otd1572896246305__section_N10025_N10022_N10001">
<h4 class="title sectiontitle">Input</h4>
<ul class="ul">
<li class="li">admissions_train, as in <a href="jjd1542828070779.md">GLM Example: Logistic Regression Analysis with Intercept</a></li></ul></div><div class="section" id="otd1572896246305__section_N10034_N10022_N10001">
<h4 class="title sectiontitle">SQL Call</h4><pre class="pre codeblock" xml:space="preserve"><code>CREATE MULTISET TABLE glm_ps_admission AS (
  SELECT * FROM GlmPerSegment (
    ON admissions_train PARTITION BY masters
    USING
    TargetColumns ('programming','stats','gpa')
    CategoricalColumns ('programming','stats')
    ResponseColumn ('admitted')
    Family ('BINOMIAL') 
  ) AS dt
) WITH DATA;
</code></pre></div><div class="section" id="otd1572896246305__section_N1003E_N10022_N10001">
<h4 class="title sectiontitle">Output</h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM glm_ps_admission ORDER BY masters, attribute;</code></pre><pre class="pre screen" xml:space="preserve">masters attribute       category estimate             mean std  information 
------- --------------- -------- -------------------- ---- ---- ----------- 
no      (Intercept)     NULL       6.6903541355663405 NULL NULL p          
no      AIC             NULL       14.928953520754312 NULL NULL NULL       
no      BIC             NULL       20.271184068131298 NULL NULL NULL       
no      Converged       NULL                     NULL NULL NULL true       
no      Encoder         NULL                     NULL NULL NULL Onehot     
no      Family          NULL                     NULL NULL NULL Binomial   
no      Feature scaling NULL                     NULL NULL NULL false      
no      Features #      NULL                      6.0 NULL NULL NULL       
no      Iterations #    NULL                    145.0 NULL NULL NULL       
no      Rows #          NULL                     18.0 NULL NULL NULL       
no      gpa             NULL       0.1483582648481284 NULL NULL p          
no      programming     beginner   1.9392522289550878 NULL NULL p          
no      programming     advanced                 NULL NULL NULL p          
no      programming     novice     -6.434784403589906 NULL NULL p          
no      stats           advanced                 NULL NULL NULL p          
no      stats           beginner    0.990404728346057 NULL NULL p          
no      stats           novice     0.3199039133220177 NULL NULL p          
yes     (Intercept)     NULL        2.189946726810501 NULL NULL p          
yes     AIC             NULL        13.16784699598212 NULL NULL NULL       
yes     BIC             NULL       19.714101716132017 NULL NULL NULL       
yes     Converged       NULL                     NULL NULL NULL true       
yes     Encoder         NULL                     NULL NULL NULL Onehot     
yes     Family          NULL                     NULL NULL NULL Binomial   
yes     Feature scaling NULL                     NULL NULL NULL false      
yes     Features #      NULL                      6.0 NULL NULL NULL       
yes     Iterations #    NULL                     66.0 NULL NULL NULL       
yes     Rows #          NULL                     22.0 NULL NULL NULL       
yes     gpa             NULL     -0.48384863214225443 NULL NULL p          
yes     programming     novice     0.6681676098960271 NULL NULL p          
yes     programming     beginner  -1.6932303573749459 NULL NULL p          
yes     programming     advanced                 NULL NULL NULL p          
yes     stats           beginner    0.285130041094017 NULL NULL p          
yes     stats           novice     -0.871130260970221 NULL NULL p          
yes     stats           advanced                 NULL NULL NULL p</pre></div></div></div></div></div>
