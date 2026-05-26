% Tr_Square
cd '/home/coleta/TR_simples';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% configuracoes %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nome do experimento
experimento = 'tr_idosos_com_instrucao';
% Eutroficos: 'tr_pn_exp2';
% Idosos: 'tr_idosos_com_instrucao';

%numero do sujeito
sjnum = '18';

%número de tentativas de pratica
ntt = 5;


%%%%%%%%%%%
%comentar a linha abaixo para ter controle dos tempos aleatorios por meio de um arquivo externo
%interval_to_change_path = '/home/coleta/TR_simples/interval_to_target_mov.txt';

%limites para o tempo entre tentativas aleatorio (caso a linha acima esteja comentada)
random_time_limits = 2:0.1:4; %limite_inferior : passos : limite_superior


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% enderecos fisicos %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
script_path = '/home/coleta/TR_simples';
%script_path = '/home/flavio/Documentos/Academic/Scripts/Octave - scripts/Psychtoolbox/TR_simples';

txt_name = sprintf('%s_suj%s.txt', experimento, sjnum); %nome do arquivo txt para salvar todas as tentativas do sujeito

mkdir(experimento); %criar uma pasta para armazenar os arquivos deste experimento

%define o caminho para ler a resposta do switch
myu3_path = '/home/coleta/LabJackPython/labjack-LJFuse/root-ljfuse/MyU3/connection/AIN0';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% carrega valores de arquivos externos %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%carrega os tempos 'aleatorios' para o movimento do alvo apos o sinal de atencao
%interval_to_change = load(interval_to_change_path);

%produz uma coluna com ntt numeros aleatorios entre 2 e 4, em intervalos de 0.1
%caso a variavel interval_to_change nao tenha sido criada no inicio do script
if ~exist ('interval_to_change', 'var')
    interval_to_change = RandSample(random_time_limits,[ntt 1]);
end

%confere se o Labjack esta habilitado
try
    dlmread(myu3_path);
catch
    error('***** O Labjack não está ativado! *****')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% preparar a tela e as cores %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%opens the active window
screenNum=0;
[wPtr,rect]=Screen('OpenWindow', screenNum); %using screen number only, the whole screen is used as default

%color parameters MUST came after openning the window
black=BlackIndex(wPtr);
white=WhiteIndex(wPtr);
red = [255 0 0];
green = [0 255 0];
yellow = [255 255 0];
proj_color = [0 255 0];

%fills the open window with black
Screen('FillRect',wPtr,black);
Screen('Flip', wPtr); %flip
HideCursor;
WaitSecs(0.1); %waits a specified time (in seconds)

%for speed
%[x_mouse, y_mouse, response] = GetMouse(wPtr); %descomentar para usar o mouse (response: buttons)
response = dlmread(myu3_path);
reaction_time_trials = [];

%determina as coordenadas do quadrado
alvo_left = (rect(RectRight)/2) - ((rect(RectBottom)/4)/2);
alvo_top = (rect(RectBottom)/2) - ((rect(RectBottom)/8)/2); %determina a distancia entre o quadrado e o topo da tela
alvo_larg = rect(RectBottom)/4;
alvo_alt = rect(RectBottom)/8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% interacao com o participante %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('TextFont',wPtr, 'Ubuntu');
Screen('TextSize',wPtr, 40);
Screen('DrawText', wPtr, 'Informe a posição corporal:', rect(RectRight)/4.6, rect(RectBottom)/2.5, [255, 255, 255]);

Screen('TextSize',wPtr, 30);
text_ntt = sprintf('1 (sentado), 2 (em pé) ou 3 (monopedal)', num2str(ntt));
Screen('DrawText', wPtr, text_ntt, rect(RectRight)/4.6, rect(RectBottom)/2, [255, 255, 255]);

Screen('Flip', wPtr); %flip

keyIsDown = 0;
while keyIsDown == 0
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    pos_corporal = KbName(keyCode); %armazena a opção escolhida
    
    if length(pos_corporal) != 1
        keyIsDown = 0;
        pos_corporal = [];
    end
    
    if (pos_corporal != '1') && (pos_corporal != '2') && (pos_corporal != '3') %just in case...
        keyIsDown = 0;
    end
    
    
end

Screen('FillRect',wPtr,black);
Screen('Flip', wPtr); %flip

Screen('TextFont',wPtr, 'Ubuntu');
Screen('TextSize',wPtr, 40);
Screen('DrawText', wPtr, 'Pressione o botão quando estiver pronto', rect(RectRight)/4.6, rect(RectBottom)/2.5, [255, 255, 255]);

Screen('TextSize',wPtr, 30);
text_ntt = sprintf('Serão %s tentativas consecutivas', num2str(ntt));
Screen('DrawText', wPtr, text_ntt, rect(RectRight)/4.6, rect(RectBottom)/2, [255, 255, 255]);
Screen('Flip', wPtr); %flip


%switch
while response < 3
    response = dlmread(myu3_path);
end

%mouse
%while response(1) == 0
%[x_mouse, y_mouse, response] = GetMouse(wPtr);
%end


%fills the open window with black
Screen('FillRect',wPtr,black);
Screen('Flip', wPtr); %flip


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% loop de tentativas %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:ntt
    
    trial = i;
    
    %washout variables
    reaction_time = [];
    stim_time = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% TR %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %fills the open window with black
    Screen('FillRect', wPtr, green, [alvo_left alvo_top (alvo_left + alvo_larg) (alvo_top + alvo_alt)]); %alvo
    response = 0;
    Screen('Flip', wPtr); %flip
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    WaitSecs(interval_to_change(trial));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %fills the square with red
    Screen('FillRect', wPtr, red, [alvo_left alvo_top (alvo_left + alvo_larg) (alvo_top + alvo_alt)]); %alvo
    
    
    response = 0;
    
    
    Screen('Flip', wPtr); %flip
    stim_time = GetSecs; %registra o tempo em que foi dado o estimulo visual
    
    
    %switch
    while response < 3
        response = dlmread(myu3_path);
    end
    
    %mouse
    %while response(1) == 0
    %[x_mouse, y_mouse, response] = GetMouse(wPtr);
    %end
    
    
    
    reaction_time = GetSecs;
    
    reaction_time_trials = [reaction_time_trials (reaction_time - stim_time)]
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% fecha o loop de tentativas %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% salva os dados da tentativa %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trial_data = [str2num(pos_corporal) reaction_time_trials];

cd(experimento); %muda para a pasta do experimento sendo conduzido

dlmwrite(txt_name, trial_data, 'delimiter', '\t', '-append');

cd(script_path); %retorna para a pasta onde esta o script


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% agradecimento %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('FillRect',wPtr,black);
Screen('Flip', wPtr);

Screen('TextSize',wPtr, 40);
Screen('DrawText', wPtr, 'OBRIGADO!', 300, 300, [255, 255, 255]);
Screen('Flip', wPtr);
[end_experiment_time, keyCode, deltaSecs] = KbWait; %aguarda o enter para encerrar o experimento



Screen('CloseAll');







