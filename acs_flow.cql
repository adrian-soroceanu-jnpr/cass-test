CREATE TABLE flow_data.acs_sflow (
    site_id text,
    server_port int,
    ts timestamp,
    server_ip text,
    export_ip text,
    client_ip text,
    client_port int,
    in_netif_name text,
    out_netif_name text,
    is_server text,
    community_id text,
    server_port_svc text,
    total_flow_bytes bigint,
    vlan_in int,
    vlan_out int,
    vxlan_vni int,
    PRIMARY KEY (site_id, server_port, ts, server_ip, export_ip, client_ip, client_port, in_netif_name, out_netif_name, is_server)
) WITH CLUSTERING ORDER BY (server_port ASC, ts DESC, server_ip ASC, export_ip ASC, client_ip ASC, client_port ASC, in_netif_name ASC, out_netif_name ASC, is_server ASC)
    AND additional_write_policy = '99p'
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
    AND cdc = false
    AND comment = ''
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.TimeWindowCompactionStrategy', 'compaction_window_size': '1', 'compaction_window_unit': 'DAYS', 'max_threshold': '32', 'min_threshold': '4'}
    AND compression = {'chunk_length_in_kb': '64', 'class': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND memtable = 'default'
    AND crc_check_chance = 1.0
    AND default_time_to_live = 2592000
    AND extensions = {}
    AND gc_grace_seconds = 86400
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair = 'BLOCKING'
    AND speculative_retry = '99p';
