import { useEffect, useMemo, useState } from 'react';
import JSZip from 'jszip';

type Message = {
  role: 'ai' | 'user';
  text: string;
};

const templateFiles = import.meta.glob('../wendyMod/dst-wendy-pub/**/*', {
  query: '?raw',
  eager: true,
  import: 'default'
}) as Record<string, string>;
const templateBasePath = '../wendyMod/dst-wendy-pub/';

const initialMessages: Message[] = [
  {
    role: 'ai',
    text: '欢迎使用 AImod Wendy 角色 mod 生成器！这会直接打包完整 Wendy mod，并生成可下载 ZIP。'
  }
];

const App = () => {
  const [messages, setMessages] = useState<Message[]>(initialMessages);
  const [modName, setModName] = useState('[DST]Wendy Rework');
  const [description, setDescription] = useState('Port DST Reworked Wendy, QoLs.');
  const [author, setAuthor] = useState('zzzzzzzs');
  const [version, setVersion] = useState('20230112');
  const [downloadUrl, setDownloadUrl] = useState<string | null>(null);
  const [status, setStatus] = useState('填写 mod 名称、描述、作者和版本，然后生成完整 ZIP。');

  const chatLog = useMemo(
    () => messages.map((message, index) => ({ ...message, id: index })),
    [messages]
  );

  useEffect(() => {
    return () => {
      if (downloadUrl) {
        URL.revokeObjectURL(downloadUrl);
      }
    };
  }, [downloadUrl]);

  const appendMessage = (message: Message) => {
    setMessages((prev) => [...prev, message]);
  };

  const patchModInfo = (content: string) => {
    return content
      .replace(/^name\s*=\s*".*"/m, `name = "${modName}"`)
      .replace(/^description\s*=\s*".*"/m, `description = "${description}"`)
      .replace(/^author\s*=\s*".*"/m, `author = "${author}"`)
      .replace(/^version\s*=\s*".*"/m, `version = "${version}"`);
  };

  const createModZip = async () => {
    const zip = new JSZip();

    for (const [importPath, rawContent] of Object.entries(templateFiles)) {
      const relativePath = importPath.replace(templateBasePath, '');
      const content = relativePath === 'modinfo.lua' ? patchModInfo(rawContent) : rawContent;
      zip.file(relativePath, content);
    }

    const blob = await zip.generateAsync({ type: 'blob' });
    const url = URL.createObjectURL(blob);

    if (downloadUrl) {
      URL.revokeObjectURL(downloadUrl);
    }

    setDownloadUrl(url);
    setStatus('完整 Wendy 角色 mod ZIP 已生成，可点击下载。');
    appendMessage({ role: 'ai', text: '已生成完整 Wendy 角色 mod ZIP。点击下载按钮获取文件。' });
  };

  return (
    <div className="app-shell">
      <header className="app-header">
        <h1>AImod Wendy 角色 mod 生成器</h1>
        <p>使用你上传的完整 Wendy mod 模板，生成并下载完整 mod ZIP 包。</p>
      </header>

      <main className="layout">
        <section className="chat-panel">
          <div className="chat-title">对话窗口</div>
          <div className="chat-history">
            {chatLog.map((message) => (
              <div key={message.id} className={`message ${message.role}`}>
                <span>{message.role === 'ai' ? 'AImod助手' : '你'}：</span>
                <p>{message.text}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="control-panel">
          <div className="card">
            <h2>Wendy 角色 mod 模板</h2>
            <p>从 <code>wendyMod/dst-wendy-pub</code> 目录打包完整 mod 文件。</p>
            <p>生成的 ZIP 会保留模板内所有文件，并自动更新 <code>modinfo.lua</code>。</p>
          </div>

          <div className="card">
            <h2>填写 mod 信息</h2>
            <label>
              Mod 名称
              <input value={modName} onChange={(event) => setModName(event.target.value)} />
            </label>
            <label>
              描述
              <textarea value={description} onChange={(event) => setDescription(event.target.value)} />
            </label>
            <label>
              作者
              <input value={author} onChange={(event) => setAuthor(event.target.value)} />
            </label>
            <label>
              版本
              <input value={version} onChange={(event) => setVersion(event.target.value)} />
            </label>
            <button className="button primary" onClick={createModZip}>
              生成完整 mod ZIP
            </button>
            {downloadUrl ? (
              <a className="button secondary" href={downloadUrl} download={`${modName.replace(/\s+/g, '_') || 'wendy-mod'}.zip`}>
                下载完整 mod
              </a>
            ) : null}
          </div>

          <div className="card status-card">
            <h2>当前状态</h2>
            <p>{status}</p>
          </div>
        </section>
      </main>
    </div>
  );
};

export default App;
