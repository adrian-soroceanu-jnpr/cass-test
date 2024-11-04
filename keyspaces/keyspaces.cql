CREATE KEYSPACE IF NOT EXISTS acs_vm_metrics WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}  AND durable_writes = true;
CREATE KEYSPACE IF NOT EXISTS flow_data WITH REPLICATION = { 'class' : 'SimpleStrategy','replication_factor' : '1'} AND durable_writes = true;
