ts=(1.47 2.9)

for THRESHOLD in ${ts[@]};
do
    ### Inputs
    numberOfProcessors=100
    numberOfSimulations=100

    coralPercent=33
    macroalgaePercent=33
    gridOption=0 #array

    #Time and Grid Settings
    rows=25
    columns=25
    neighborhoodThreshold=$THRESHOLD

    recordRate=10
    imageReturn=false #lowercase spelling true or false
    imageRecordRate=1 ## after how many recordings do you want an image saved? 1 = each time the other recordings are taken

        ## table for first run. later averages
    #loop through g, nested loop through gridoption (once ready)
    r=1.0
    d=.4
    a=.2
    g=.53 #array
    y=.75
    dt=.1
    tf=11 #can play with this value as well
    tims=$tf

    blobValue=0

    ## create directory
   grazingFolder=$(python -c "print(str(round($g*100)))")
   thresholdFolder=$(python -c "print(int($neighborhoodThreshold*100))")


    mkdir -p 'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder

    ## run simulation
    python coralModel_functions.py $numberOfProcessors $numberOfSimulations $coralPercent $macroalgaePercent $gridOption $rows $columns $neighborhoodThreshold $recordRate $imageReturn $imageRecordRate $r $d $a $g $y $dt $tf $blobValue
    
  # Zig-zag parameters
    organism=0
    group=1
    denoise1=8
    denoise2=99
    compute_wasserstein=0
    isUnion=0

    blobValue=0

    ## create directory
   grazingFolder=$(python -c "print(str(round($g*100)))")
   thresholdFolder=$(python -c "print(int($neighborhoodThreshold*100))")

 # create directory for bars
    mkdir -p 'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder/'bars'
    
    # generate bars
    python PL_grazing_print_barcodes.py $numberOfProcessors $numberOfSimulations $coralPercent $macroalgaePercent $gridOption $rows $columns $neighborhoodThreshold $recordRate $imageReturn $imageRecordRate $r $d $a $g $y $dt $tf $organism $group $denoise1 $denoise2 $isUnion $tims

    # convert to landscapes
    xargs <./'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder/'bars'/'c'$coralPercent'm'$macroalgaePercent'all_bars_list_hdim0.txt' -I filename ./gudhi.3.3.0/build/utilities/Persistence_representations/persistence_landscapes/create_landscapes -1 "filename"

    # compute average landscape
    ./gudhi.3.3.0/build/utilities/Persistence_representations/persistence_landscapes/average_landscapes $(cat ./'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder/'bars'/'c'$coralPercent'm'$macroalgaePercent'all_lands_list_hdim0.txt')

    mv average.land ./'output'/$rows'x'$columns/'grid'$gridOption/'grazing'$grazingFolder/'threshold'$thresholdFolder/'bars'/
done
