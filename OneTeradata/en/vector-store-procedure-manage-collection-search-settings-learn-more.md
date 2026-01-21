After indexing, you query the vector store to retrieve relevant data. The system compares your query to stored vectors and returns top-k matches. The results depend on the vector store type:

You can continue with the defaults or select required values by disabling Use defaults.

- Similarity matches: Select the number (between 1 to 1024) of similarity matches to generate.
- Similarity threshold: To consider matching tables and views.

General settings:

Select Euclidean, or Cosine, or Dotproduct.

- Euclidean: Computes the similarity using euclidean distance between the vectors.
- Cosine: Computes the cosine similarity (normalized dot product) between two vectors.
- Dot Product: Computes the similarity between vectors using dot product.

