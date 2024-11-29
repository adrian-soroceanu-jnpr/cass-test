CREATE TABLE IF NOT EXISTS acs_vm_metrics.vm_ips_15m (
    site_id text,
    ts timestamp,
    h_host text,
    vm_name text,
    vm_ip text,
    port_grp text,
    ip_typ text,
    PRIMARY KEY (site_id, ts, h_host, vm_name, vm_ip)
) WITH CLUSTERING ORDER BY (ts DESC, h_host ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
    AND comment = ''
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.TimeWindowCompactionStrategy', 'compaction_window_size': '1', 'compaction_window_unit': 'DAYS', 'max_threshold': '32', 'min_threshold': '4'}
    AND compression = {'chunk_length_in_kb': '64', 'class': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND default_time_to_live = 2592000
    AND gc_grace_seconds = 86400
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND speculative_retry = '99PERCENTILE';%     
