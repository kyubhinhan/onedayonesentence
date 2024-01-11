// 필요한 모듈 가져오기
import express from 'express';

// Express 애플리케이션 생성
const app = express();
const port = 3000; // 사용할 포트 번호

// 루트 엔드포인트에 대한 핸들러
app.get('/', (req, res) => {
    res.send('안녕하세요, Node.js 서버!');
});

// 서버 시작
app.listen(port, () => {
    console.log(`서버가 http://localhost:${port} 에서 실행 중입니다.`);
});