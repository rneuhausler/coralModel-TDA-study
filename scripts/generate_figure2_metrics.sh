# Inputs
numberOfProcessors=100
numberOfSimulations=100
coralPercent=33
macroalgaePercent=33
gridOption=0

# Time and Grid Settings
rows=25
columns=25
neighborhoodThreshold=1.45
recordRate=10
imageReturn=false
imageRecordRate=1 

# Parameters
r=1.0
d=.4
a=.2
g=.57
y=.75
dt=.1
tf=101
blobValue=0

# Zig-zag parameters
organism=0
group=1
isUnion=0

isCoral=1

# create directory
grazingFolder=$(python -c "print(str(round($g*100)))")
thresholdFolder=$(python -c "print(int($neighborhoodThreshold*100))")                        
mkdir -p 'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder

tims=$tf

# run simulation
python coralModel_functions.py $numberOfProcessors $numberOfSimulations $coralPercent $macroalgaePercent $gridOption $rows $columns $neighborhoodThreshold $recordRate $imageReturn $imageRecordRate $r $d $a $g $y $dt $tf $blobValue $organism $group
	                    
# create directory for bars
mkdir -p 'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder/'bars'

python PL_grazing_print_barcodes.py $numberOfProcessors $numberOfSimulations $coralPercent $macroalgaePercent $gridOption $rows $columns $neighborhoodThreshold $recordRate $imageReturn $imageRecordRate $r $d $a $g $y $dt $tf $organism $group $isUnion $tims
	                
# convert to landscapes
xargs <./'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder/'bars'/'c'$coralPercent'm'$macroalgaePercent'all_bars_list_hdim0.txt' -I filename ./gudhi.3.3.0/build/utilities/Persistence_representations/persistence_landscapes/create_landscapes -1 "filename"

# compute average landscape
./gudhi.3.3.0/build/utilities/Persistence_representations/persistence_landscapes/average_landscapes $(cat ./'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder/'bars'/'c'$coralPercent'm'$macroalgaePercent'all_lands_list_hdim0.txt')

mv average.land ./'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder/'bars'/

