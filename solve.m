%% File Info.

%{

    solve.m
    -------
    This code solves the model.

%}

%% Solve class.

classdef solve
    methods(Static)
        function sol = lc(par)
            %% Structure array for model solution.
            sol = struct();

            %% Model parameters, grids and functions.
            T = par.T;
            tr = par.tr;

            beta = par.beta;
            nu = par.nu;
            gamma = par.gamma;
            sigma = par.sigma;

            alen = par.alen;
            agrid = par.agrid;

            ylen = par.ylen;
            ygrid = par.ygrid;
            pmat = par.pmat;
            Gmat = par.Gmat;

            r = par.r;
            kappa = par.kappa;

            %% Containers
            v1 = nan(alen, T, ylen);
            a1 = nan(alen, T, ylen);
            c1 = nan(alen, T, ylen);
            n1 = nan(alen, T, ylen);

            amat = repmat(agrid, 1, ylen);
            ymat = repmat(ygrid, alen, 1);

            fprintf('------------Solving from the Last Period of Life.------------\n\n');

            for age = 1:T

                if T-age+1 == T
                    % Terminal period: consume all, no labor
                    c1(:, T, :) = amat + kappa * ymat;
                    a1(:, T, :) = 0.0;
                    n1(:, T, :) = 0.0;
                    v1(:, T, :) = model.utility(c1(:, T, :), n1(:, T, :), par);
                else
                    for i = 1:ylen
                        if T-age+1 >= tr
                            yt_const = kappa * ygrid(i);
                            ev = v1(:, T-age+2, i);
                        else
                            ev = squeeze(v1(:, T-age+2, :)) * pmat(i, :)';
                        end

                        for p = 1:alen
                            vall = nan(alen, 1);
                            ctvec = nan(alen, 1);
                            ntvec = nan(alen, 1);

                            for j = 1:alen
                                a_prime = agrid(j);

                                if T-age+1 >= tr
                                    nt = 0.0;
                                    yt = yt_const;
                                else
                                    yt_fun = @(n) Gmat(age) * ygrid(i) * n;
                                    cfun = @(n) agrid(p) + yt_fun(n) - a_prime / (1 + r);
                                    foc = @(n) ((1 - n).^(1/nu)) - ((cfun(n).^(-sigma)) / gamma);
                                    [n_opt, ~] = fminbnd(foc, 0.01, 0.99);
                                    nt = n_opt;
                                    yt = yt_fun(nt);
                                end

                                ctemp = agrid(p) + yt - a_prime / (1 + r);
                                if ctemp <= 0
                                    ctemp = 0;
                                    val = -inf;
                                else
                                    val = model.utility(ctemp, nt, par) + beta * ev(j);
                                end

                                vall(j) = val;
                                ctvec(j) = ctemp;
                                ntvec(j) = nt;
                            end

                            [vmax, ind] = max(vall);
                            v1(p, T-age+1, i) = vmax;
                            c1(p, T-age+1, i) = ctvec(ind);
                            a1(p, T-age+1, i) = agrid(ind);
                            n1(p, T-age+1, i) = ntvec(ind);
                        end
                    end
                end

                if mod(T-age+1, 5) == 0
                    fprintf('Age: %d.\n', T-age+1);
                end
            end

            fprintf('------------Life Cycle Problem Solved.------------\n');

            %% Store solution
            sol.c = c1;
            sol.a = a1;
            sol.v = v1;
            sol.n = n1;
        end
    end
end
