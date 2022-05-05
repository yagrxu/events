By default, the Kubernetes scheduler uses a bin-packing algorithm to fit as many pods as possible into a cluster. The scheduler prefers a more evenly distributed general node load to app replicas precisely spread across nodes. Therefore, by default, multi-replica is not guaranteed multi-AZ.


For production services, we use explicit pod anti-affinity to ensure replicas are distributed between AZs.

