#reads vanilla entity group file and creates the appends for all groups based on game stages
#	Only changes groups with names in $entityGroupNames
#	Any group with gamestage number less than values used in variables will get new monsters added
#
#
$vanilla_entityGroupsFile = 'E:\SteamLibrary\steamapps\common\7 Days To Die\Data\Config\entitygroups.xml'
$output_file = "$PWD\entitygroups_edited.xml"

#entitygroups to change
$entityGroupNames = @(
	'wanderingHordeStageGS',
	'FwanderingHordeStageGS',
	'sleeperHordeStageGS',
	'badassHordeStageGS',
	'scoutHordeStageGS',
	'feralHordeStageGS',
	'policeCarHordeStageGS',
	'defenseHordeStageGS'
	)

#gamestage settings
$beginStage = 60 #set to first occurance of a feral in BM Horde (no spawns added to GS groups below this value)
$earlyGamestage = 100  #set to first occurance of feral cop in BM Horde
$midGamestage = 140 #set to first occurance of radiated in BM Horde
$midlateGamestage = 190 #set to first occurance of radiated cop in BM Horde
$lateGamestage = 99999

#probability templates
$veryRareProb = '0.01'
$rareProb = '.05'
$lowProb = '.1'
$medProb = '.5'

#entity templates inserted into entitygroups
$earlyTemplate = (
	"`t`t<entity name=`"zombieFireBowStripper`" prob=`"$veryRareProb`"/>"
	)
$midTemplate = (
	"`t`t<entity name=`"zombieFireBowStripper`" prob=`"$lowProb`"/>",
	"`t`t<entity name=`"animalWolfElectric`" prob=`"$veryRareProb`"/>",
	"`t`t<entity name=`"animalWolfFire`" prob=`"$veryRareProb`"/>"
	)
$midlateTemplate = (
	"`t`t<entity name=`"zombieFireBowStripper`" prob=`"$medProb`"/>",
	"`t`t<entity name=`"animalWolfElectric`" prob=`"$lowProb`"/>",
	"`t`t<entity name=`"animalWolfFire`" prob=`"$lowProb`"/>",
	"`t`t<entity name=`"zombieclaus`" prob=`"$veryRareProb`"/>"
	)
$lateTemplate = (
	"`t`t<entity name=`"zombieFireBowStripper`"/>",
	"`t`t<entity name=`"animalWolfElectric`" prob=`"$medProb`"/>",
	"`t`t<entity name=`"animalWolfFire`" prob=`"$medProb`"/>",
	"`t`t<entity name=`"zombieclaus`" prob=`"$rareProb`"/>",
	"`t`t<entity name=`"animalZombieElectricDragon`" prob=`"$veryRareProb`"/>",
	"`t`t<entity name=`"animalZombieFireDragon`" prob=`"$veryRareProb`"/>"
	)

$outputLines = @("`t<!-- BEGIN AUTO-GENERATED HORDE LIST APPENDS -->")
$entityGroupsLines = Get-Content -Path $vanilla_entityGroupsFile

foreach ($line in $entityGroupsLines) {
	foreach ($group in $entityGroupNames) {
		if($line -match """($group(\d+))") {
			#write-host ($Matches[1] + "---" + $Matches[2])
			
			#skip early gamestages
			if([int]$Matches[2] -lt $beginStage) {
				continue
			}
			
			#find lines that match our entity groups and grab gamestage number
			$outputLines += "`t<append xpath=""/entitygroups/entitygroup[starts-with(@name,'$group" + $Matches[2] + "')]"">"
			if([int]$Matches[2] -lt $earlyGamestage) { #early GS inserts
				$outputLines += $earlyTemplate
			} elseif([int]$Matches[2] -lt $midGamestage) { #mid GS inserts
				$outputLines += $midTemplate
			} elseif([int]$Matches[2] -lt $midlateGamestage) { #midlate GS inserts
				$outputLines += $midlateTemplate
			} elseif([int]$Matches[2] -lt $lateGamestage) { #late GS inserts
				$outputLines += $lateTemplate
			}
			$outputLines += "`t</append>"
		}
	}
}
$outputLines += ("`t<!-- END AUTO-GENERATED HORDE LIST APPENDS -->")
Set-Content -Value $outputLines -Path $output_file