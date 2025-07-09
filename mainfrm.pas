unit mainfrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, httpsend, ssl_openssl, fpjson, jsonparser, Messages, IniFiles;

type

  TChatMessage = record
    Role: string;
    Content: string;
  end;

  { TMainForm }

  TMainForm = class(TForm)
    chathistoryLbl: TLabel;
    NewChatBtn: TButton;
    ChatmessageMemo: TMemo;
    ChatHistoryMemo: TMemo;
    ModelEdt: TEdit;
    UrlEdt: TEdit;
    SendBtn: TButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure NewChatBtnClick(Sender: TObject);
    procedure SendBtnClick(Sender: TObject);
  private
    ChatHistory: array of TChatMessage;
    ChatMessageIndex: Integer;
    function CallOllamaChat(const OllamaURL, Model: string;
      const History: array of TChatMessage): string;

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.SendBtnClick(Sender: TObject);
var
  Reply: string;
begin
  // Add user message to history
  ChatMessageIndex := ChatMessageIndex + 1;
  SetLength(ChatHistory, ChatMessageIndex + 1);
  ChatHistory[ChatMessageIndex].Role := 'user';
  ChatHistory[ChatMessageIndex].Content := ChatMessageMemo.Text;

  // Append user message to ChatHistoryMemo
  ChatHistoryMemo.Lines.Add('🧑 You:');
  ChatHistoryMemo.Lines.Add(ChatMessageMemo.Text);
  ChatHistoryMemo.Lines.Add('');  // blank line

  // Call Ollama with full conversation history
  Reply := CallOllamaChat(UrlEdt.Text, ModelEdt.Text, ChatHistory);
  //showmessage(Reply);

  // Add assistant response to history
  ChatMessageIndex := ChatMessageIndex + 1;
  SetLength(ChatHistory, ChatMessageIndex + 1);
  ChatHistory[ChatMessageIndex].Role := 'assistant';
  ChatHistory[ChatMessageIndex].Content := Reply;

  // Append assistant message to ChatHistoryMemo
  ChatHistoryMemo.Lines.Add('🤖 AI:');
//  ChatHistoryMemo.Lines.Add(Reply);
  ChatHistoryMemo.Lines.Text := ChatHistoryMemo.Lines.Text + Reply;
  ChatHistoryMemo.Lines.Add('');  // blank line

  with ChatHistoryMemo do
  begin
    SelStart := Length(Text); // Move cursor to end
    SelLength := 0;           // No selection
    Perform(EM_SCROLLCARET, 0, 0); // Scroll to caret
  end;

  // Optional: Clear input box for next message
  ChatMessageMemo.Clear;
end;



procedure TMainForm.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
  IniFileName: string;
begin
  ChatMessageIndex := -1;
  SetLength(ChatHistory, 0);
  IniFileName := ExtractFilePath(ParamStr(0)) + 'settings.ini';
  Ini := TIniFile.Create(IniFileName);
  try
    UrlEdt.Text := Ini.ReadString('Settings', 'Url', '');
    ModelEdt.Text := Ini.ReadString('Settings', 'Model', '');
  finally
    Ini.Free;
  end;
end;

procedure TMainForm.NewChatBtnClick(Sender: TObject);
begin
  begin
    // Clear visible memo
    ChatHistoryMemo.Clear;

    // Reset conversation history array
    SetLength(ChatHistory, 0);

    // Reset message index
    ChatMessageIndex := -1;

    // Optional: clear input box too
    ChatMessageMemo.Clear;

    // Optional: put a welcome message
    ChatHistoryMemo.Lines.Add('💬 New chat started...');
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  Ini: TIniFile;
  IniFileName: string;
begin
  IniFileName := ExtractFilePath(ParamStr(0)) + 'settings.ini';
  Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteString('Settings', 'Url', UrlEdt.Text);
    Ini.WriteString('Settings', 'Model', ModelEdt.Text);
  finally
    Ini.Free;
  end;
end;

function TMainForm.CallOllamaChat(const OllamaURL, Model: string; const History: array of TChatMessage): string;
var
  HTTP: THTTPSend;
  RequestJSON, MsgObj: TJSONObject;
  MessagesArr: TJSONArray;
  ResponseStream: TStringStream;
  Lines: TStringList;
  i: Integer;
  ResponseJSON: TJSONObject;
  Part: string;
begin
  Result := '';
  HTTP := THTTPSend.Create;
  try
    HTTP.Sock.CreateWithSSL(TSSLOpenSSL);  // initialize SSL
    HTTP.Headers.Clear;
    HTTP.Headers.Add('Content-Type: application/json');

    // Build JSON payload
    RequestJSON := TJSONObject.Create;
    MessagesArr := TJSONArray.Create;
    try
      RequestJSON.Add('model', Model);

      for i := Low(History) to High(History) do
      begin
        MsgObj := TJSONObject.Create;
        MsgObj.Add('role', History[i].Role);
        MsgObj.Add('content', History[i].Content);
        MessagesArr.Add(MsgObj);
      end;

      RequestJSON.Add('messages', MessagesArr);

      // Send the request
      HTTP.Document.Clear;
      ResponseStream := TStringStream.Create(RequestJSON.AsJSON);
      try
        ResponseStream.Position := 0;
        HTTP.Document.LoadFromStream(ResponseStream);

        if HTTP.HTTPMethod('POST', OllamaURL + '/api/chat') then
        begin
          // Read the whole response
          ResponseStream.Clear;
          HTTP.Document.Position := 0;
          ResponseStream.CopyFrom(HTTP.Document, HTTP.Document.Size);
          ResponseStream.Position := 0;

          // Split response into lines (each line is a JSON chunk)
          Lines := TStringList.Create;
          try
            Lines.Text := ResponseStream.DataString;
            Result := '';
            for i := 0 to Lines.Count - 1 do
            begin
              if Trim(Lines[i]) = '' then
                Continue;
              ResponseJSON := GetJSON(Lines[i]) as TJSONObject;
              try
                Part := ResponseJSON.FindPath('message.content').AsString;
                Result := Result + Part;
              finally
                ResponseJSON.Free;
              end;
            end;

          finally
            Lines.Free;
          end;
        end
        else
          Result := 'HTTP Error: ' + HTTP.ResultString;
      finally
        ResponseStream.Free;
      end;
    finally
      RequestJSON.Free;
    end;
  finally
    HTTP.Free;
  end;

  Result := TrimRight(Result);
end;


end.

