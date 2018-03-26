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
bpy.ops.mesh.quads_convert_to_tris(quad_method='BEAUTY', ngon_method='BEAUTY')

vertices = bmesh.from_edit_mesh(blenderObject.data).verts
normals = [v.normal for v in vertices]

normalTxt = open(normDest,'w')
for n in normals:
    normal = str(n[0])+','+str(n[1])+','+str(n[2])+'\n'
    normalTxt.write(normal)
normalTxt.close()

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
