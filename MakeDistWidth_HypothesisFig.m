function MakeDistWidth_HypothesisFig

% this makes the shaded distributional hypothesis panel from the paper. 
% the rest of the figure was made in Illustrator

cm = flipud(gray(1.5*numel([1:.001:2])));

figure ;
set(gcf,'renderer','Painters');
hold on
x = [-5:.01:5];
ctr = 0;
for s = 1:.001:2
    ctr = ctr+1;
y = normpdf(x,0,s);

plot(x,y,'color',cm(ctr,:));
end
plot(x,y,'color',cm(ctr,:),'LineWidth',4);

y = normpdf(x,0,1);
cm2=lines(1);
plot(x,y,'color',cm2,'LineWidth',4);

axx = gca;
axx.YAxis.Visible = 'off'; % remove y-axis
xticks([]);
set(gca,'LineWidth',3);




end % of function