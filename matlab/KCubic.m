clear
%% unit cell model definition
Lx = 1; Ly = 1; Lz = 1;
r0 = 1e-2; t = r0/4;
Es = 7e7; nu = 0.3; Gm = Es/2/(1+nu);
Area = r0^2;
Ixx = r0^4/12;

nodes = [0, 0, 0; Lx, 0, 0;
    0, Ly, 0; 0, 0, Lz;
    Lx, 0, Lz; 0, Ly, Lz;
    Lx, Ly, 0; Lx, Ly, Lz];

beams = struct('nodes', [1,2; 1,3; 1,4; 8,7; 8,5; 8,6;...
    4,5; 4,6; 5,2; 3,6; 7,2; 7,3]);

mat = struct('E', Es, 'nu', nu);
prop.beams = struct('A', Area, ...
    'Ixx', Ixx, 'Iyy', Ixx, 'Izz', 2*Ixx);
model = struct('nodes', nodes, 'beams',  beams, ...
    'mat', mat, 'prop', prop);
disp('cubic topology');
%% periodic directions
dirs = [01, 02; 01, 03; 01, 04];
a1 = (model.nodes(dirs(1,2),:)-model.nodes(dirs(1,1), :))';
a2 = (model.nodes(dirs(2,2),:)-model.nodes(dirs(2,1), :))';
a3 = (model.nodes(dirs(3,2),:)-model.nodes(dirs(3,1), :))';
%% plot unit cell
figure(4); clf

plot3DModel(model, [],...
    struct('nodeslabels', false, 'FontSize', 18, ...
    'plotundef', true, 'undeflinewidth', 1, 'undeflinestyle', '-', ...
    'undeflinecolor', 'b'));

plot3DModel(model, [],...
    struct('nodeslabels', true, 'FontSize', 18, ...
    'plotundef', true, 'undeflinewidth', 6, 'undeflinestyle', '-'));
xlabel('x'); ylabel('y'); zlabel('z');

daspect([1, 1, 1]); view(3)
light('Position',[1 1 1],'Style','infinite');
set(gca, 'Visible', 'off')
myaxis = axis;
shg
p0 = -[1,1,1]/10;
cg = mean(nodes);
set(quiver3(cg(1), cg(2), cg(3), a1(1), a1(2), a1(3), 1), ...
    'linewidth', 2, 'color', 'b');
set(text(cg(1)+a1(1), cg(2)+a1(2), cg(3)+a1(3), 'a$_1$'), ...
    'fontSize', 18, 'interpreter', 'latex');

set(quiver3(cg(1), cg(2), cg(3), a2(1), a2(2), a2(3), 1), ...
    'linewidth', 2, 'color', 'b');
set(text(cg(1)+a2(1), cg(2)+a2(2), cg(3)+a2(3), 'a$_2$'), ...
    'fontSize', 18, 'interpreter', 'latex');
set(quiver3(cg(1), cg(2), cg(3), a3(1), a3(2), a3(3), 1), ...
    'linewidth', 2, 'color', 'b');
set(text(cg(1)+a3(1), cg(2)+a3(2), cg(3)+a3(3), 'a$_3$'), ...
    'fontSize', 18, 'interpreter', 'latex');

camlight; lighting phong; material metal;
alpha (0.25);
%% find material properties
[Keps, Vol, Vol0, deps] = Find3DMatProp(model, a1, a2, a3);

fprintf ('the material volume of the unit cell is : %.4f\n', Vol);
fprintf ('the volume of the unit cell is          : %.4f\n', Vol0);
fprintf ('the relative density of the lattice is  : %.4f\n', Vol/Vol0);
fprintf ('the lattice stiffnes matrix is : \n');
disp (Keps);
%% plot pure deformation modes of the unit cell

nnodes = size(model.nodes,1);
stitles = {{'$\epsilon_{11} = 1, \epsilon_{22} = 0, \epsilon_{33} = 0$', ...
    '$\gamma_{12} = 0, \gamma_{23} = 0, \gamma_{31} = 0$'}, ...
    {'$\epsilon_{11} = 0, \epsilon_{22} = 1, \epsilon_{33} = 0$', ...
    '$\gamma_{12} = 0, \gamma_{23} = 0, \gamma_{31} = 0$'}, ...
    {'$\epsilon_{11} = 0, \epsilon_{22} = 0, \epsilon_{33} = 1$', ...
    '$\gamma_{12} = 0, \gamma_{23} = 0, \gamma_{31} = 0$'}, ...
    {'$\epsilon_{11} = 0, \epsilon_{22} = 0, \epsilon_{33} = 0$', ...
    '$\gamma_{12} = 0, \gamma_{23} = 1, \gamma_{31} = 0$'}, ...
    {'$\epsilon_{11} = 0, \epsilon_{22} = 0, \epsilon_{33} = 0$', ...
    '$\gamma_{12} = 0, \gamma_{23} = 0, \gamma_{31} = 1$'}, ...
    {'$\epsilon_{11} = 0, \epsilon_{22} = 0, \epsilon_{33} = 0$', ...
    '$\gamma_{12} = 1, \gamma_{23} = 0, \gamma_{31} = 0$'}};

figure(2); clf
set(gcf, 'position', [20, 400, 1200, 800]);
for nMode = 1:6
    subplot(2, 3, nMode); set(gca, 'fontSize', 14);
    
    disp0 = reshape(deps(:,nMode), 6, nnodes)';
    plot3DModel(model, disp0,...
        struct('nodeslabels', false, 'FontSize', 18, ...
        'plotundef', true, 'undeflinewidth', 2, 'undeflinestyle', '-', ...
        'plotdef', true, 'linewidth', 4, 'maxdisp', 0.3,...
        'drawplates', false, 'NPoints', 20, ...
        'drawfaces', true, 'facecolor', 'g'));
    set(title(stitles{nMode}), 'interpreter', 'latex');
    set(xlabel('x$_1$'), 'interpreter', 'latex');
    set(ylabel('x$_2$'), 'interpreter', 'latex');
    set(zlabel('x$_3$'), 'interpreter', 'latex');
    set(gca, 'xtick', [], 'ytick', [], 'ztick', []);
    view (-13.5, 12);
end
shg

