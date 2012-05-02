function [F0, G] = fitelastic(X, Y)

func=fittype('a+b*x+c*x^2','indep','x');
[F0, G]=fit(X, log(Y), func,...
            'StartPoint',[1 1 1 ]);

figure(1)
plot(X, log(Y), X, F0(X)); grid on;

figure(2)
plot(X, Y, X, exp(F0(X))); grid on;

