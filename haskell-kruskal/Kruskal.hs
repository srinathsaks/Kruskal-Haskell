module Kruskal
(
  Node,
  Edge,
  Graph,
  fromText,
  kruskal,
  totalWeight,
)
where

import Data.List
import System.IO

type Node = String
type Edge = ([Node], Float)
type Graph = ([Node], [Edge])

fromText :: String -> Graph
fromText strLines = 
  let readData [n1, n2, w] = ([n1, n2], read w :: Float)
      es = map (readData . words) $ lines strLines
  in fromList es

fromList :: [([String], Float)] -> Graph
fromList es =
  let ns = nub . concatMap fst $ es
  in (ns, es)    

incidentEdges :: [Edge] -> Node -> [Edge]
incidentEdges es n = filter (\(ns,_) -> n `elem` ns) es

connectedEdges :: [Edge] -> [Node] -> [Edge]
connectedEdges es ns = 
  let incidents = nub . concatMap (incidentEdges es) $ ns
      nodes = nodesInEdges incidents
  in  if length nodes == length ns then incidents
      else connectedEdges es nodes

containsCycles :: [Edge] -> Bool
containsCycles es = length es >= length (nodesInEdges es) 

containsCyclesWithEdge :: [Edge] -> Edge -> Bool
containsCyclesWithEdge es (ns,_) = 
    let cnEs = connectedEdges es ns
    in containsCycles cnEs

nodesInEdges :: [Edge] -> [Node]
nodesInEdges = nub . concatMap (\(ns,_) -> ns)

kruskal :: Graph -> Graph
kruskal ([],_) = error "Graph contains no nodes"
kruskal g@(ns,es) = kruskal' g (ns,[])

kruskal' :: Graph -> Graph -> Graph
kruskal' gOrig gNew
  | nodeCt gNew == 1 + edgeCt gNew = gNew
  | otherwise =
      let gNew' = addEdge gOrig gNew
      in kruskal' gOrig gNew'

addEdge :: Graph -> Graph -> Graph
addEdge gOrig@(nsO, esO) gNew@(nsN, esN) =
  let edges = sortBy (\(_,w1) (_,w2) -> compare w1 w2) (esO \\ esN)
  in addFirstNonCycling edges gNew

addFirstNonCycling :: [Edge] -> Graph -> Graph
addFirstNonCycling (e@(ens,_):rest) g@(ns,es) = 
  let es' = e:es
      g' = (ns,es')
      cyclesWithEdge = containsCycles (connectedEdges es' ens)
  in  if cyclesWithEdge then addFirstNonCycling rest g
      else g'


nodeCt :: Graph -> Int
nodeCt (ns,_) = length ns

edgeCt :: Graph -> Int
edgeCt (_,es) = length es

totalWeight :: Graph -> Float
totalWeight (_,es) = sum . map (\(_,w) -> w) $ es
