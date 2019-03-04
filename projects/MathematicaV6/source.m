(* ::Package:: *)

(* ::Title:: *)
(*The Cover Image*)


(* ::Subtitle:: *)
(*Making the Mathematica 6 Surface-Textured Hyperbolic Dodecahedron *)
(**)


(* ::Author:: *)
(* *)
(*Michael Trott *)
(*\[Copyright] Michael Trott 2007*)
(**)


(* ::Section:: *)
(*Outline of the Procedure*)


(* ::Text:: *)
(*1. We start with a regular dodecahedron centered at the origin.*)


(* ::Text:: *)
(*2. The faces of the dodecahedron are divided into five isosceles triangles.*)


(* ::Text:: *)
(*3. An L-shaped polygon is subdivided recursively into smaller copies.*)


(* ::Text:: *)
(*4. The subdivided L's are mapped onto the subdivided dodecahedron.*)


(* ::Text:: *)
(*5. A radial transformation is applied to each L. Then each triangle is given depth by connecting it to a slightly smaller copy moved closer to the origin.*)


(* ::Section:: *)
(*Step 1: The Regular Dodecahedron*)


(* ::Commentary:: *)
(*Here is a regular dodecahedron.*)


PolyhedronData["Dodecahedron"]


(* ::Section:: *)
(*Step 2: Dividing the Faces into Triangles*)


(* ::Commentary:: *)
(* This divides the faces of the dodecahedron into isosceles triangles. *)


dodecahedronTriangles = N[Flatten[Function[l, Module[{mp = 1 / 5 Plus @@ l[[1]]}, (Polygon[Append[#, mp]]&) /@
	Partition[Append[l[[1]], l[[1, 1]]], 2, 1]]] /@ N[Map[PolyhedronData["Dodecahedron", "VertexCoordinates"][[#]]&,
	Polygon /@ PolyhedronData["Dodecahedron", "FaceIndices"], {-1}], 100]]];


(* ::Commentary:: *)
(*Here is the result.*)


Graphics3D[dodecahedronTriangles]


(* ::Commentary:: *)
(* For later use, we calculate the minimal and maximal distances of the dodecahedron surface to the origin. *)


{Subscript[\[Rho], min], Subscript[\[Rho], max]} = {Min[#], Max[#]}&[Norm /@ Union[Level[dodecahedronTriangles, {-2}]]];


(* ::Section:: *)
(*Step 3: Subdividing the L-Shaped Polygons*)


(* ::Commentary:: *)
(* This defines two L-shaped polygons. *)


Ls[1] = Polygon /@ ( {{{0, 2}, {0, 0}, {2, 0}, {2, 1}, {1, 1}, {1, 2}, {0, 2}}, {{0, 3}, {2, 3}, {2, 1}, {1, 1}, {1, 2}, {0, 2}, {0, 3}}} / 2);


(* ::Commentary:: *)
(* The function splitLIntoFourLs subdivides each L into four smaller L's. *)


splitLIntoFourLs[Polygon[l_]] := Polygon /@ (({{2 #1 + 2 #2, 4 #2, 2 #2 + 2 #3, #2 + #3 + 2 #5, 2 #2 + 2 #5, #1 + #2 + 2 #5, 2 #1 + 2 #2}, {#1 + #2 + 2 #6, 2 #2 + 2 #5, #2 + #3 + 2 #4, 2 #4 + 2 #5, 4 #5, 2 #5 + 2 #6, #1 + #2 + 2 #6}, {2 #2 + 2 #3, 4 #3, 4 #4, 2 #4 + 2 #5, #2 + #3 + 2 #4, #2 + #3 + 2 #5, 2 #2 + 2 #3}, {4 #6, 4 #1, 2 #1 + 2 #2, #1 + #2 + 2 #5, #1 + #2 + 2 #6, 2 #5 + 2 #6, 4 #6}} / 4)& @@ l)


(* ::Commentary:: *)
(*Here are the original two L-shaped polygons and the first three iterations of the splitting process.*)


Ls[k_] := Ls[k] = Flatten[splitLIntoFourLs /@ Ls[k - 1], 1]


GraphicsRow[Table[Graphics[Line @@@ Ls[j]], {j, 1, 4}]]


(* ::Section:: *)
(*Step 4: Mapping the L's onto the Dodecahedron*)


(* ::Commentary:: *)
(*The function mapPointToDodecahedronTriangle maps points to the triangle dodecahedronTriangle on the dodecahedron. The function mapLToDodecahedronTriangle maps a whole L-shaped polygon into the dodecahedron. The mapping is done such that the original double-L rectangle covers a triangle on the dodecahedron.*)


mapPointToDodecahedronTriangle[{x_, y_}, dodecahedronTriangle : Polygon[{p1_, p2_, p3_}]] := 1 / 3 (p3 (3 - 2 y) + 2 (p1 - p1 x + p2 x) y)


mapLToDodecahedronTriangle[L_, dodecahedronTriangle : Polygon[{p1_, p2_, p3_}] ] := Map[mapPointToDodecahedronTriangle[#, dodecahedronTriangle ]&, L, {2}]


(* ::Commentary:: *)
(*This lists all L's on the surface of the dodecahedron. (Use Ls[4] instead of Ls[2] to generate the full cover image.)*)


LsOnDodecahedron = Function[t, mapLToDodecahedronTriangle[#, t]& /@ Ls[4]] /@ dodecahedronTriangles;


LsOnDodecahedron // Flatten // Length


(* ::Commentary:: *)
(*The L's are contracted slightly to display their boundaries more clearly.*)


contractL[L : Polygon[l_]] := With[{mp = (l[[2]] + l[[5]]) / 2, \[Alpha] = 0.8}, Polygon[(mp + \[Alpha] (# - mp)&) /@ l]]


Graphics3D[LsOnDodecahedron /. p_Polygon :> contractL[p]]


(* ::Section:: *)
(*Step 5: Applying a Radial Transformation and Thickening*)


(* ::Commentary:: *)
(* The function \[ScriptCapitalF] induces a radial transformation of the coordinates. *)


\[ScriptCapitalF][\[Alpha]_, xyz_, f_] := \[Alpha] xyz f[(Sqrt[xyz.xyz] - Subscript[\[Rho], min]) / (Subscript[\[Rho], max] - Subscript[\[Rho], min])]


(* ::Commentary:: *)
(*Using f(r)\[Congruent]1 keeps the faces of the dodecahedron flat.*)


\[ScriptF][r_] := 1;


(* ::Commentary:: *)
(*The function addHatToL adds a small "hat" onto each of the L's.*)


addHatToL[L : Polygon[l_]] :=
	Module[{mp = Plus @@ l / 7, qs, \[ScriptR], \[CurlyPhi], mpF, rs},
		qs = (\[ScriptCapitalF][1, #, \[ScriptF]]&) /@ l;\[ScriptR] = Sqrt[#.#]&[Plus @@ l / 7];\[CurlyPhi] = (\[ScriptR] - Subscript[\[Rho], min]) / (Subscript[\[Rho], max] - Subscript[\[Rho], min]);mpF = \[ScriptCapitalF][1.06, mp, \[ScriptF]];rs = (\[ScriptCapitalF][1.06, mp + 0.6 (# - mp), \[ScriptF]]&) /@ l;{{extensionColor[\[CurlyPhi]], Specularity[extensionColor[\[CurlyPhi]], extensionSpecularExponent[\[CurlyPhi]]], extensionOpacity[\[CurlyPhi]], (Polygon[Append[#1, mpF]]&) /@ Partition[Append[rs, First[rs]], 2, 1]}, {baseColor[RandomReal[{\[CurlyPhi] - 0.2, \[CurlyPhi] + 0.2}]], Specularity[baseColor[\[CurlyPhi]], 2.3], baseOpacity[\[CurlyPhi]], Polygon[Join[#1, Reverse[#2]]]& @@@ Transpose[Partition[Append[#, First[#]], 2, 1]& /@ {qs, rs}]}}]


(* ::Commentary:: *)
(*The base and the extension of the hats are colored differently. In addition, to emphasize the edges of the dodecahedron, a color variation is added across its faces.*)


baseColor[\[Xi]_] := Hue[0.1 - 0.11\[Xi], 0.5 + 0.5\[Xi], 1];
baseOpacity[\[Xi]_] := Opacity[0.35 + 0.65(1 - (1 - \[Xi]^2)^(1 / 2))];
extensionColor[\[Xi]_] := Hue[0.05 - 0.2If[(1 - (1 - \[Xi]^2)^(1 / 2)) > 0.3, 0.3, (1 - (1 - \[Xi]^2)^(1 / 2))], 0.5 + 0.8\[Xi], 1 - 0.35(1 - (1 - \[Xi]^2)^(1 / 2))];
extensionOpacity[\[Xi]_] := Opacity[0.4 + 0.4\[Xi]];
extensionSpecularExponent[\[Xi]_] := 2.5\[Xi];


(* ::Commentary:: *)
(* Here is the resulting surface-textured dodecahedron.*)


Graphics3D[{EdgeForm[], addHatToL /@ Take[Flatten[Take[LsOnDodecahedron, All]], All]}, PlotRange -> All, Boxed -> False, ImageSize -> 300, Lighting -> {{"Ambient", RGBColor[0.2, 0, 0]}, {"Point", RGBColor[0.4, 0.4, 0.4], {2, 0, 2}}, {"Point", RGBColor[0.4, 0.4, 0.4], {2, 2, 2}}, {"Point", RGBColor[0.4, 0.4, 0.4], {0, 2, 2}}, {"Point", RGBColor[0.2, 0, 0], {-2, -2, -2}}}]


(* ::Commentary:: *)
(*To make the dodecahedron hyperbolic, we now extrude its vertices and intrude the centers of the faces. We use a new function f for the radial transformation.*)


\[ScriptF][r_] := Re[1 / 2 (ArcSin[2 r - 1] + \[Pi] / 2)];


Plot[\[ScriptF][r], {r, 0, Subscript[\[Rho], max]}]


(* ::Commentary:: *)
(*The next input generates a version of the cover image with less detail. *)


Graphics3D[{EdgeForm[], addHatToL /@ Take[Flatten[Take[LsOnDodecahedron, All]], All]}, PlotRange -> All, Boxed -> False, ImageSize -> 300, Lighting -> {{"Ambient", RGBColor[0.2, 0, 0]}, {"Point", RGBColor[0.4, 0.4, 0.4], {2, 0, 2}}, {"Point", RGBColor[0.4, 0.4, 0.4], {2, 2, 2}}, {"Point", RGBColor[0.4, 0.4, 0.4], {0, 2, 2}}, {"Point", RGBColor[0.2, 0, 0], {-2, -2, -2}}}]
