#!/usr/bin/awk -f

BEGIN {
    index_drop = 1;
	drop_nodo[0] = 0;
    drop_value[0] = 0;
    num = 0;
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
	
			
	if ( action == "d" ) {
        num++;
        trigger = 0;
        for (i = 0; i < index_drop; i++) {
            if (drop_nodo[i] == from) {
                drop_value[i] += 1;
                trigger = 1;
                break;
            }
        }

        if (trigger == 0) {
            drop_nodo[index_drop] = from;
            drop_value[index_drop] = 1;
            index_drop++;
        }        

    }

}
END {
    for (i = 0; i < index_drop; i++) {
        #print("drop_node[",i,"] = ", drop_nodo[i], ", drop_value[",i,"] = ", drop_value[i] );
        if (drop_value[i] != 0) { 
           # print(drop_nodo[i], ",", drop_value[i] );
            print(drop_nodo[i], ";", "Nodo", drop_nodo[i], ";", drop_value[i] / num * 100 );
        }
    }
    #print(num);
}
