<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="kbf1507569393238" id="kbf1507569393238"><h1 class="title topictitle1" id="ariaid-title1">TFIDF (ML Engine)</h1><div class="body conbody">
<p class="p">TF-IDF stands for "term frequency-inverse document frequency," a technique for evaluating the importance of a specific term in a specific document in a document set. Term frequency (<var class="keyword varname">tf</var>) is the number of times that the term appears in the document and inverse document frequency (<var class="keyword varname">idf</var>) is the number of times that the term appears in the document set. The TF-IDF score for a term is <var class="keyword varname">tf</var> *<var class="keyword varname">idf</var>. A term with a high TF-IDF score is especially relevant to the specific document.</p>
<p class="p">The TFIDF function can do either of the following:</p>
<ul class="ul" id="kbf1507569393238__ul_cts_gmv_q1b">
<li class="li">Take any document set and output the inverse document frequency (IDF)
				and term frequency- inverse document frequency (TF-IDF) scores for each term.</li>
<li class="li">Use the output of a previous run of the TFIDF function on a training document set to predict TFIDF scores of an input (test) document set.</li></ul><div class="p">You can use the TF-IDF scores as input for many document clustering and
			classification algorithms, including:
<ul class="ul" id="kbf1507569393238__ul_znx_xxp_yx">
<li class="li">Cosine-similarity</li>
<li class="li">Latent Dirichlet allocation</li>
<li class="li">K-means clustering</li>
<li class="li">K-nearest neighbors</li></ul></div>
<p class="p">You can use the TF-IDF scores derived from a training document set to create a model in a classification function (for example, <a href="kjz1558533259127.md#swn1507915086903">SVMSparse (ML Engine)</a>) and then use the resulting TF-IDF scores in a classification prediction function (for example, <a href="wzb1541537305621.md#guu1507914686828">SVMSparsePredict_MLE (ML Engine)</a>).</p>
<p class="p">The TFIDF function represents each document as an <var class="keyword varname">N</var>-dimensional vector, where <var class="keyword varname">N</var> is the number of terms in the document set (therefore, the document vector is usually very sparse). Each entry in the document vector is the TF-IDF score of a term.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="fmu1507569524200" xml:lang="en-us" lang="en-us" id="fmu1507569524200">
<h2 class="title topictitle2" id="ariaid-title2">TFIDF Syntax</h2><div class="body refbody"><div class="section" id="fmu1507569524200__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">TFIDF version 2.3, TF version 1.2</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM TFIDF (
  ON TF (
    <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY <var class="keyword varname">docid</var>     
    [ USING Formula ({ 'normal' | 'bool' | 'log' | 'augment' }) ]
  ) AS TF PARTITION BY <var class="keyword varname">term</var> 
  [ ON (SELECT COUNT (DISTINCT <var class="keyword varname">docid</var>) FROM <var class="keyword varname">doccount_table</var>) AS DocCount DIMENSION ]
  [ ON (SELECT <var class="keyword varname">term</var>, COUNT (DISTINCT <var class="keyword varname">docid</var>) FROM <var class="keyword varname">docperterm_table</var> GROUP BY <var class="keyword varname">term</var>)
      AS DocPerTerm PARTITION BY <var class="keyword varname">term</var>
  ]
  [ ON (SELECT DISTINCT (<var class="keyword varname">term</var>) AS term, idf FROM <var class="keyword varname">tf_idf_output_table</var>)
      AS IDF PARTITION BY <var class="keyword varname">term</var>
  ]
) AS <var class="keyword varname">alias</var>;</code></pre></div><div class="section" id="fmu1507569524200__section_sql_hcz_wy">
<h3 class="title sectiontitle">Large Document Sets</h3>
<p class="p">For large documents sets, the DocPerTerm table is required.</p>
<p class="p">For training, this is the syntax for large document sets:</p><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM TFIDF (
  ON TF (
    <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY <var class="keyword varname">docid</var>      
    [ USING Formula ({ 'normal' | 'bool' | 'log' | 'augment' }) ]
  ) AS TF PARTITION BY <var class="keyword varname">term</var> 
  ON (SELECT COUNT (DISTINCT <var class="keyword varname">docid</var>) FROM <var class="keyword varname">doccount_table</var>) AS DocCount DIMENSION
  ON (SELECT <var class="keyword varname">term</var>, COUNT (DISTINCT <var class="keyword varname">docid</var>) FROM <var class="keyword varname">docperterm_table</var> GROUP BY <var class="keyword varname">term</var>)
    AS DocPerTerm PARTITION BY <var class="keyword varname">term</var> 
) AS <var class="keyword varname">alias</var> ORDER BY <var class="keyword varname">docid</var>;</code></pre>
<p class="p">For prediction, this is the syntax for large document sets:</p><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM TFIDF (
  ON TF (
    <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY <var class="keyword varname">docid</var>      
    [ USING Formula ({ 'normal' | 'bool' | 'log' | 'augment' }) ]
  ) AS TF PARTITION BY <var class="keyword varname">term</var> 
  [ ON (SELECT <var class="keyword varname">term</var>, COUNT (DISTINCT <var class="keyword varname">docid</var>) FROM <var class="keyword varname">docperterm_table</var> GROUP BY <var class="keyword varname">term</var>)
      AS DocPerTerm PARTITION BY <var class="keyword varname">term</var>
  ]
  [ ON (SELECT DISTINCT (<var class="keyword varname">term</var>) AS <var class="keyword varname">term</var>, idf FROM <var class="keyword varname">tf_idf_output_table</var>)
      AS IDF PARTITION BY <var class="keyword varname">term</var>
  ]
) AS <var class="keyword varname">alias</var> ORDER BY <var class="keyword varname">docid</var>;</code></pre></div><div class="section" id="fmu1507569524200__section_upw_gcz_wy">
<h3 class="title sectiontitle">Small Document Sets</h3>
<p class="p">This syntax is acceptable for small document sets:</p><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM TFIDF (
  ON TF (
    <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY <var class="keyword varname">docid</var> 
  ) AS TF PARTITION BY <var class="keyword varname">term</var> 
  ON (SELECT COUNT (DISTINCT <var class="keyword varname">docid</var>) FROM <var class="keyword varname">input_table</var>) AS DocCount DIMENSION
) AS <var class="keyword varname">alias</var> ORDER BY <var class="keyword varname">docid</var>;</code></pre></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="yup1507569536124" xml:lang="en-us" lang="en-us" id="yup1507569536124">
<h2 class="title topictitle2" id="ariaid-title3">TFIDF Syntax Elements</h2><div class="body refbody"><div class="section" id="yup1507569536124__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">Formula</dt><dd class="dd pd">[Optional] Specify the formula for calculating the term frequency (tf) of term <var class="keyword varname">t</var> in document <var class="keyword varname">d</var>:
<div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="yup1507569536124__table_rns_4lz_fdb" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:25%" span="1"></col><col style="width:75%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d84010e364" rowspan="1" colspan="1">Option</th><th class="entry cellrowborder" style="vertical-align:top;" id="d84010e366" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d84010e364" rowspan="1" colspan="1"><code class="ph codeph">'normal'</code> (Default)</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d84010e366" rowspan="1" colspan="1">Normalized frequency:
<p class="p"><code class="ph codeph">tf(<var class="keyword varname">t</var>,<var class="keyword varname">d</var>) = f ((<var class="keyword varname">t</var>,<var class="keyword varname">d</var>) / sum {<var class="keyword varname">w</var>,<var class="keyword varname">w</var> ∈<var class="keyword varname">d</var>}</code></p>
<p class="p">This value is <var class="keyword varname">rf</var> divided by number of terms in document.</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d84010e364" rowspan="1" colspan="1"><code class="ph codeph">'bool'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d84010e366" rowspan="1" colspan="1">Boolean frequency:
<p class="p"><code class="ph codeph">tf((<var class="keyword varname">t</var>,<var class="keyword varname">d</var>) = 1</code> if <var class="keyword varname">t</var> occurs in <var class="keyword varname">d</var>; otherwise, <code class="ph codeph">tf((<var class="keyword varname">t</var>,<var class="keyword varname">d</var>) = 0</code>.</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d84010e364" rowspan="1" colspan="1"><code class="ph codeph">'log'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d84010e366" rowspan="1" colspan="1">Logarithmically-scaled frequency:
<p class="p"><code class="ph codeph">tf((<var class="keyword varname">t</var>,<var class="keyword varname">d</var>) = log(f((<var class="keyword varname">t</var>,<var class="keyword varname">d</var>)+1)</code></p>
<p class="p">where <code class="ph codeph">f((<var class="keyword varname">t</var>,<var class="keyword varname">d</var>)</code> is the number of times <var class="keyword varname">t</var> occurs in <var class="keyword varname">d</var> (that is, raw frequency, <var class="keyword varname">rf</var>).</p></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d84010e364" rowspan="1" colspan="1"><code class="ph codeph">'augment'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d84010e366" rowspan="1" colspan="1">Augmented frequency, which prevents bias towards longer documents:
<p class="p"><code class="ph codeph">tf((<var class="keyword varname">t</var>,<var class="keyword varname">d</var>) = 0.5 + (0.5 × f ((<var class="keyword varname">t</var>,<var class="keyword varname">d</var>) / max {f(<var class="keyword varname">w</var>,<var class="keyword varname">d</var>) : <var class="keyword varname">w</var> ∈<var class="keyword varname">d</var> })</code></p>
<p class="p">This value is <var class="keyword varname">rf</var> divided by maximum raw frequency of any term in document.</p></td></tr></tbody></table></div>
<p class="p">When using the output of a previous run of the TFIDF function on a training document set to predict TFIDF scores on an input document set, use the same Formula value for the input document set that you used for the training document set.</p></dd></dl></div></div></div></div>
