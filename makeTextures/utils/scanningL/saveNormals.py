#!/usr/bin/python

import sys

sys.path.append("/Library/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages")

import os
import csv
import bpy
import bmesh

# shape = 'L'
# s = sys.argv[5]

inFile = sys.argv[5] # ('spec/' + shape + '_' + str(s))
normDest = inFile + '_norm.txt'
faceDest = inFile + '_face.txt'
uvDest = inFile + '_uv.txt'

try:
    with open(inFile+'_face.txt', newline='') as inputfile:
        faceSpec = list(csv.reader(inputfile))
    inputfile.close()
    with open(inFile+'_vert.txt', newline='') as inputfile:
        vertSpec = list(csv.reader(inputfile))
    inputfile.close()

except:
        print("Error: unable to fetch data")

edges = []

faces = []
for face in faceSpec:
    faces.append((int(face[0])-1,int(face[1])-1,int(face[2])-1,int(face[3])-1))

vertsForNormals = []
for vertex in vertSpec:
    vertsForNormals.append((float(vertex[0]),float(vertex[1]),float(vertex[2])))

# assemble Alden medial axis object FOR NORMAL EXPORT
blenderMesh = bpy.data.meshes.new('L_mesh')
blenderMesh.from_pydata(vertsForNormals,edges,faces)
blenderObject = bpy.data.objects.new('L', blenderMesh)

bpy.ops.object.select_all(action='DESELECT')
bpy.context.scene.objects.link(blenderObject)
bpy.context.scene.objects.active = blenderObject
blenderObject.select = True

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.fill_holes()
bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.mesh.faces_shade_smooth()
bpy.ops.mesh.mark_sharp(clear=True, use_verts=True)

o = float(sys.argv[6])

if (o%180==0):
    possibilities = [0] + [48+64*n for n in range(148)] + [9473] + [16+64*n for n in range(31)] + [16+64*n for n in range(117,148)]
else:
    possibilities = [0] + [(48+16*((o%180)/90)) + 64*n for n in range(148)] + [(16+16*((o%180)/90)) +64*n for n in range(148)] + [9473]

# if seam == 'innerSeam':
#     possibilities = [0] + [48+64*n for n in range(148)] + [9474] + [16+64*n for n in range(148)]
# else:
#     possibilities = [0] + [16+64*n for n in range(148)] + [9474] + [48+64*n for n in range(148)]

bpy.ops.mesh.select_mode(type='EDGE')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.quads_convert_to_tris(quad_method='BEAUTY',ngon_method='BEAUTY')
bpy.ops.mesh.select_all(action='DESELECT')

edges = bmesh.from_edit_mesh(blenderObject.data).edges

for edge in edges:
    if edge.verts[0].index in possibilities and edge.verts[1].index in possibilities:
        edge.select = True
    else:
        edge.select = False

bpy.ops.mesh.mark_seam(clear=False)

bpy.ops.object.mode_set(mode='OBJECT')
accessWP = [sv for sv in blenderObject.vertex_groups if sv.name.startswith('decimateGroup')]

if len(accessWP) == 0:
    blenderObject.vertex_groups.new(name='decimateGroup')
    accessWP = [sv for sv in blenderObject.vertex_groups if sv.name.startswith('decimateGroup')]

decimateGroup = accessWP[0]

for capVert in [n for n in range(1985)]:
    decimateGroup.add([capVert],1.0,'ADD')

for capVert in [n for n in range(9474-1985,9475)]:
    decimateGroup.add([capVert],1.0,'ADD')

bpy.ops.object.modifier_add(type='DECIMATE')
blenderObject.modifiers['Decimate'].vertex_group = 'decimateGroup'
blenderObject.modifiers['Decimate'].ratio = 0.6
bpy.ops.object.modifier_apply(apply_as='DATA',modifier='Decimate')

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.unwrap(method='ANGLE_BASED',margin=0.001)
bpy.ops.object.mode_set(mode='OBJECT')
comboSpec = []

for face in blenderObject.data.polygons:
    uvCurrentFace = []
    for vert,loop in zip(face.vertices,face.loop_indices):
        uvCurrentFace += [uv for uv in blenderObject.data.uv_layers.active.data[loop].uv]
    comboSpec.append(uvCurrentFace)

uvTxt = open(uvDest,'w')
for uv in comboSpec:
    uvEntry = str(uv[0])+','+str(uv[1])+','+str(uv[2])+','+str(uv[3])+','+str(uv[4])+','+str(uv[5])+'\n'
    uvTxt.write(uvEntry)
uvTxt.close()

bpy.ops.object.mode_set(mode='EDIT')

vertices = bmesh.from_edit_mesh(blenderObject.data).verts
normals = [v.normal for v in vertices]

normalTxt = open(normDest,'w')
for n in normals:
    normal = str(n[0])+','+str(n[1])+','+str(n[2])+'\n'
    normalTxt.write(normal)
normalTxt.close()

vert = [v.co for v in vertices]
vertTxt = open(inFile+'_vert.txt','w')
for n in vert:
    v = str(n[0])+','+str(n[1])+','+str(n[2])+'\n'
    vertTxt.write(v)
vertTxt.close()

faces = bmesh.from_edit_mesh(blenderObject.data).faces
ff = [[v.index for v in f.verts] for f in faces]

faceTxt = open(faceDest,'w')
for f in ff:
    face = str(f[0]+1)+','+str(f[1]+1)+','+str(f[2]+1)+'\n'
    faceTxt.write(face)
faceTxt.close()

bpy.ops.object.mode_set(mode='OBJECT')

bpy.ops.object.select_all(action='DESELECT')
bpy.context.scene.objects.active = blenderObject
blenderObject.select = True
