for file in *.cql; do
            echo "Applying $file to Cassandra on remote host $host..."
            ssh -o StrictHostKeyChecking=no root@10.49.233.67 "cqlsh -f $file"
        done
