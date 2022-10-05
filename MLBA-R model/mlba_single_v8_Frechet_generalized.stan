functions{

      real lba_pdf(real t, real b, real v, real alpha){
          //PDF of the LBA model

          real pdf;
          // here, better to use Frechet as given as a function by rstan probably, as faster?
          if(t<=0){pdf=1e-10;}else{
          if(v<=0){pdf=1e-10;}else{
          //pdf = (v/b)*exp(-v*t/b);
          pdf = exp(weibull_lpdf(t|alpha, b/v));
        }}

          return pdf;
     }



     real lba_cdf(real t, real b, real v, real alpha){
          //CDF of the LBA model


          real cdf;

          if(t<=0){cdf=1e-10;}else{
          //cdf = 1-exp(-v*t/b);
          if(v<=0){cdf=1e-10;}else{
          cdf = weibull_cdf(t,alpha, b/v);
        }}

          return cdf;

     }

  vector CurveFun(row_vector option, real m) {

          vector[2] u;
          
          // Mapping objective to subjective values (Appendix C)

          // x and y intercepts of the line of indifference, which is in the direction of the unit-length vector 1/sqrt(2)*[-1,1]
          // subjective values for the option on the curve (x/a)^m + (y/b)^m
          u[1] = (option[1] + option[2])/((option[2]/option[1])^m+1)^(1/m) ;
          u[2] = (option[1] + option[2])/((option[1]/option[2])^m+1)^(1/m);
          return u;
        }


  real Weight1(real A, real B, real lambda) {
  // Attention weights (equation 4)

    real wt;

	wt = exp(-lambda*fabs(A-B));

    return wt;
    }

 real Valuation(vector option1, vector option2, real lambda, real beta) {
// Valuation function (equation 3)
  real v;
  real beta2;
  beta2 = lambda*beta;

  v = Weight1(option1[1], option2[1], lambda)*(option1[1] - option2[1]) + Weight1(option1[2], option2[2], beta2)*(option1[2] - option2[2]);
  return v;
}

 row_vector getDrifts(row_vector stimuli, real I_0, real m, real lambda, real gamma, real beta) {

    // Calculates the mean drift rates for MLBA
    // stimuli is a 3x2 matrix with the attributes of each option

    // Beta seems to be a multiplier that is applied to the second attribute to allow it to differ from the first
    // Gamma seems to be a multiplier to transform things to "drift scale"
            row_vector[3] d;
            vector[2] u1;
            vector[2] u2;
            vector[2] u3;

            u1[1:2] = CurveFun(stimuli[1:2], m);
            u2[1:2] = CurveFun(stimuli[3:4], m);
            u3[1:2] = CurveFun(stimuli[5:6], m);

            d[1] = gamma*Valuation(u1, u2, lambda, beta) + gamma*Valuation(u1, u3, lambda, beta) + I_0;
            if (d[1] < 0) {d[1]=0;}
            d[2] = gamma*Valuation(u2, u1, lambda, beta) + gamma*Valuation(u2, u3, lambda, beta) + I_0;
            if (d[2] < 0) {d[2]=0;}
            d[3] = gamma*Valuation(u3, u1, lambda, beta) + gamma*Valuation(u3, u2, lambda, beta) + I_0;
            if (d[3] < 0) {d[3]=0;}

            return d;
          }

     real lba_log(matrix RT, real k, real I, real m, real lam, real gamma, real beta, real tau, real alpha){

          vector[rows(RT)] t;
          real b;
          vector[rows(RT)] cdf;
          vector[rows(RT)] pdf;
          vector[rows(RT)] prob;
          matrix[rows(RT), 6] stimuli;
          matrix[rows(RT), 3] v;

          b = k;
          
          for (i in 1:rows(RT)){
            
            v[i,1:3] = getDrifts(RT[i,9:14],I,m,lam,gamma,beta);
            
                    cdf[i] = 1;
                    // change this to use formula of probas
                    for(j in 1:3){
                         if(RT[i,2] == j){
                              pdf[i] = lba_pdf(RT[i,1], b, v[i,j], alpha);
                         }else{
                              cdf[i] = (1-lba_cdf(RT[i,1], b, v[i,j], alpha)) * cdf[i];
                         }
                    }
          
                    prob[i] = pdf[i]*cdf[i];
                    if(prob[i] < 1e-10){
                          prob[i] = 1e-10;
                     }
        
              
          }

          return sum(log(prob));
     }

    vector lba_rng(row_vector stimulus, real k, real I, real m, real lam, real gamma, real beta, real tau, real delta, real alpha){

          int get_pos_drift;
          int no_pos_drift;
          int get_first_pos;
          row_vector[3] v;
          vector[3] drift;
          real tau_r;
          real delta_r;
          int max_iter;
          int iter;
          real ttf[3];
          int resp[3];
          real rt;
          vector[2] pred;
          real b;
         
          //decoy vector
          // change this to go over each row of actual choices and simulate choices

          v[1:3] = getDrifts(stimulus,I,m,lam,gamma,beta);
 
          for(j in 1:3){
                drift[j] = v[j]*frechet_rng(alpha,1);
                             }
          
           b = k;
           
          for(i in 1:num_elements(v)){
                    //finish times
                    ttf[i] = b/drift[i]+tau;
               }
               //rt is the fastest accumulator finish time
               //if one is negative get the positive drift
          resp = sort_indices_asc(ttf);
          ttf = sort_asc(ttf);
          
          delta_r=uniform_rng(0,1);
          tau_r=uniform_rng(0,tau);
          if(delta_r>delta){
            pred[1] = ttf[1];
            pred[2] = resp[1];
          }else{
            pred[1] = tau_r;
            pred[2] = categorical_rng(rep_vector(inv(3), 3));
            }           
           

          return pred;
     }

}


data{
     int LENGTH;
     matrix[LENGTH,14] RT;
     int NUM_CHOICES;
}

parameters {
//     real<lower=0> k;
//     real<lower=0> tau;
     real<lower=0> I;
     real<lower=0> m;
     real<lower=0> lam;
     real<lower=0> gamma;
     real<lower=0> beta;
     real<lower=0> alpha;
 }

 transformed parameters {
    real k;
    real tau;
    real delta;
    k=1;
    tau=0;
    delta=0;
 }

 model {
      I ~ normal(1,1)T[0,];
      m ~ normal(1,1)T[0,];
      lam ~ normal(1,1)T[0,];
      gamma ~ normal(1,1)T[0,];
      beta ~ normal(1,1)T[0,];
      alpha ~ normal(1,1)T[0,];
      RT ~ lba(k, I, m, lam, gamma, beta, tau, alpha);
 }

// warning, here, generate prediction based on first menu. Look into how to generate more general predictions?

 generated quantities {
      //vector[2] pred;
      //pred = lba_rng(RT[1,9:14], k, I, m, lam, gamma, beta, tau, alpha);
      }
