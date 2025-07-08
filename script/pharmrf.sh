
flg=1
for file in $(cat pdblist | tr " " "~")
do
	pdbfile=`echo $file | cut -d "~" -f 1`

	hetid=`echo $file | cut -d "~" -f 2`
	path=`pwd`
	echo "$pdbfile search het atom $hetid"

	fpocket -f "$path/pdbs/$pdbfile.pdb" -i 1 -d  > tmp.out
	sz=`grep -c $hetid tmp.out`
	linepck=""
	if test $sz -gt 0
	then
		linepck=`cat tmp.out | grep "$hetid" | tr " " "~" | cut -d "~" -f 2-20 | tr "~" "," | head -n 1`
	else
		linepck="$hetid not found by fpocket"
		flg=0
	fi
	echo $flg	
	if test $flg -eq 1
	then
		#Fpocket output to final
                echo "$pdbfile, $hetid, $linepck" >> final.txt

		plip -f "/home/binlab/Spr_Outputs/pdbs/$pdbfile.pdb" -x > report.xml
		sed '/<longname>'$hetid'/,/\mappings/!d;/mappings/q' report.xml > output.txt
		grep -oc 'hydrophobic_interaction id' output.txt >> create.txt
		grep -oc 'hydrogen_bond id' output.txt  >> create.txt
		grep -oc 'water_bridge id' output.txt >> create.txt
		grep -oc 'salt_bridge id' output.txt  >> create.txt
		grep -oc 'pi_stack id' output.txt  >> create.txt
		grep -oc 'pi_cation_interaction id' output.txt  >> create.txt
		grep -oc 'halogen_bond id' output.txt  >> create.txt
		grep -oc 'metal_complex id' output.txt >> create.txt
		tr '\n' ',' < create.txt > output.txt
		rm create.txt

		cat final.txt output.txt | tr '\n' ', ' >> results.txt
		echo "" >> results.txt
		rm final.txt
	else
                echo "$pdbfile, $hetid, $linepck" >> finalp.txt
	fi
	flg=1	


	
	
	
done
