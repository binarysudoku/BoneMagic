/** 
Copyright 2017 James Somervail
*/

MainWindow = newRolloutFloater "BoneMagic" 200 201

/*		BONEBRIDGE		*/
fn getBoneEnd bn =
	(
	return ((preTransLate bn.transform [(bn.inode.stretchTM.scale.x *bn.length),0,0]).pos)
	)

fn linkBones par chi =
	(
	endpos = getBoneEnd par
	lbone = BoneSys.createBone endpos chi.pos [0,0,1]
	chi.parent = lbone --parent child bone to new bridge bone
	lbone.parent = par --parent new bridge bone to parent bone
	)

/*		POINTBONES		*/

fn findRoot obj =
	(
	local i = obj
	if (i == undefined) do (return 0)
	while (i.parent != undefined) do
		(
		i = i.parent
		)
	return i
	)

fn createBonesFromHeirarchy obj par c =
	(
	
	for i in obj.children do
		(
		print i
		
		lbone = BoneSys.createBone obj.pos i.pos [0,0,1]
		lbone.parent = par
		
		createBonesFromHeirarchy i lbone c
		
		if (c) do (delete i)
		)
	)

-------------------------------------------------------

global selected

rollout BoneBridge "Bridge Bones" width:162 height:57
(
	pickbutton 'selparent' "Parent Bone" pos:[3,3] width:148 height:23 enabled:true toolTip:"Select parent bone" align:#left 
 
 
	button 'apply' "Bridge Selection to Parent" pos:[3,30] width:148 height:23 toolTip:"Create bridge bones from selection to parent bone" align:#left 
 
 
	
	
	on selparent picked obj do
	(
	if classof obj == BoneGeometry do
		(
		selected = obj
		)
	)
	on apply pressed do
	(
	for i in $selection as array do
		(
		linkBones selected i
		)
	)
)

rollout PointBones "Heirarchy To Bones" width:162 height:57
(
	button 'create' "Create Bones from Heirarchy" pos:[3,26] width:155 height:28 toolTip:"Create bones from Existing Heirarchy" align:#left 
	checkbox 'docleanup' "Auto Cleanup" pos:[5,4] width:83 height:20 toolTip:"Automatically delete heirarchy when creating bones" align:#left
	
	local clean = false
	
	on docleanup changed state do
		(
		clean = state
		)
	
	on create pressed do
		(
		local root = findRoot selection[1]
		undo on
			(
			rootbone = BoneSys.createBone [root.pos.x,root.pos.y,0] [root.pos.x,root.pos.y,5] [0,0,1]
			createBonesFromHeirarchy root rootbone clean
			if (clean) do (delete root)
			)
		)
)

addrollout BoneBridge MainWindow
addrollout PointBones MainWindow