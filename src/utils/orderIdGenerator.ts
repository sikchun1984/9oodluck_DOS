let lastGeneratedTime = 0;
let sequence = 0;

export function generateOrderId(): string {
  const now = new Date();
  const timestamp = now.getTime();
  
  // Reset sequence if we're in a new millisecond
  if (timestamp !== lastGeneratedTime) {
    sequence = 0;
    lastGeneratedTime = timestamp;
  } else {
    sequence++;
  }

  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  
  // Use sequence number padded to 4 digits
  const seqNum = String(sequence % 10000).padStart(4, '0');
  
  return `${year}${month}${day}${hours}${minutes}${seqNum}`;
}