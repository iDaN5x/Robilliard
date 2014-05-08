function [line] = buildLine(pointA, pointB)
m = (pointB.y-pointA.y)/(pointB.x-pointA.x);
line(1) = -m; line(2) = 1; line(3) = (m*pointA.x - pointA.y);
end