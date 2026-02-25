You can select the Search algorithms and also set search settings from this page.

Based on your selections, you'll various options.

##### Vector-Distance

When you select Vector-Distance, in the Search settings you can continue with the defaults or select required values by disabling Use defaults. You can modify:

- Similarity matches: Select the number (between 1 to 1024) of similarity matches to generate.
- Similarity threshold: To consider matching tables and views.
- General settings: Select Euclidean, or Cosine, or Dotproduct.

•Euclidean: Computes the similarity using euclidean distance between the vectors.

•Cosine: Computes the cosine similarity (normalized dot product) between two vectors.

•Dot Product: Computes the similarity between vectors using dot product.



##### K-Means

When you select K-Means, you can continue with the defaults or select required values by disabling Use defaults. You can modify:

- Indexing Settings: Select the required values, such as, number of clusters to train, number of iterations to run, initial seed value, Centroid initialization algorithm (Random or Kmeans++), and so on.
- Search settings: Select the training cluster to count, similarity matches, and threshold values.
- General settings: Select Euclidean, or Cosine, or Dotproduct

##### HNSW

When you select HNSW, you can continue with the defaults or select required values by disabling Use defaults. You can modify:

- Indexing settings: Select the number of layers for the graph, number of node connections, EF construction values, and so on.
- Search settings: Select the similarity matches and EF search values.
- General settings: Select Euclidean, or Cosine, or Dotproduct.