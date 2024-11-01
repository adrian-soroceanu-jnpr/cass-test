CREATE KEYSPACE IF NOT EXISTS flow_data WITH REPLICATION = {
'class' : 'SimpleStrategy',
'replication_factor' : 3
} AND durable_writes = true;
