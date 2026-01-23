Teradata Vector collections supports a variety of algorithms for indexing and searching within vector stores:   

- VectorDistance: The TD_VectorDistance function computes the similarity or dissimilarity between two vectors in a multi-dimensional space.
- KMeans: The k-means algorithm groups observations into k clusters, assigning each observation to the nearest cluster centroid. This facilitates clustering and efficient retrieval of similar data.
- HNSW (Hierarchical Navigable Small World): A graph-based algorithm enabling approximate nearest neighbor search, allowing for fast and scalable retrieval in large vector databases.
- Choose VectorDistance if:
- Small datasets: If your index has fewer than 10k-100k vectors, exact search is fast enough.
- Perfect accuracy is required: You cannot accept any approximation in the results.
- Choose KMeans if:
- Memory usage is a constraint: You have limited memory and need to store indexes on disk or smaller RAM instances.
- Your data is mostly static: The database doesn't change frequently (e.g., a set product catalog).
- You need to balance memory and speed: You can afford a slight drop in accuracy to save on infrastructure costs.
- Choose HNSW if:
- Speed is your top priority: You need low-latency, real-time results for millions of users.
- You need high recall: You cannot afford to lose relevant search results (e.g., high-accuracy RAG systems).
- Your data is dynamic: You are constantly adding, updating, or deleting vectors (e.g., new product listings, live chat).
- Memory is not a bottleneck: You have enough RAM to store the graph structure.