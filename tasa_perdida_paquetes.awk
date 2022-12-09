#!/usr/bin/awk -f

BEGIN {
	highest_packet_id = 0;
    drop_packets = 0;
}
{
	action = $1;
	time = $2;
	from = $3;
	to = $4;
	type = $5;
	pktsize = $6;
	flow_id = $8;
	src = $9;
	dst = $10;
	seq_no = $11;
	packet_id = $12;
	
	if ( packet_id > highest_packet_id )
		highest_packet_id = packet_id;
			
	if ( action == "d" )
        drop_packets = drop_packets + 1;

    
}
END {
    total_packets =  highest_packet_id + 1;
    tasa_drops = drop_packets / total_packets * 100;
    #print("drop packets :", drop_packets);
    #print("packets creados :", total_packets);
    #print("tasa de drop :", tasa_drops);
    if (drop_packets != 0) {
        print(total_packets, ";", drop_packets, ";" , tasa_drops);
    }
}
