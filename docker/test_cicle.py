import sys
import os
import logging
import threading
import time


#--- переменная условие остановки программы
stop_execution = False

def arrAppend(lst, lim):
  for i in range(0,lim):
    lst.append(i)

def arrMult(lst, ml):
  for i in range(len(lst)):
    lst[i] *= ml

def taskListWorking():
  print("<<< Тестовая программа для проверки докера >>>\n")
  
  print("Исходный список")  
  lst = [98,99,100]
  print(lst, end="\n")
  
  print("Дополненный список")    
  arrAppend(lst,10)
  print(lst, end="\n")
  
  print("Умноженный на константу список")
  arrMult(lst,3)  
  print(lst, end="\n")
  logging.info(f"Умноженный на константу список: {lst}\n")
  print("<<< ---------------------------------------->>>\n")
    
cnt = 0
def backgroundTask(cnt, pause):
  global stop_execution
  
  while True:
    print("backgroundTask etap: ", cnt)
    logging.info(f"backgroundTask etap: {cnt}\n")

    print("\n")
    cnt += 1
    time.sleep(pause)
    if (cnt > maxcnt):
      stop_execution = True
      break

def startTimerInterval(interval):
  global stop_execution
  
  if (not stop_execution):
      threading.Timer(interval,
                  startTimerInterval,
                  args=[interval]).start()
      taskListWorking()

def main():
  global maxcnt  
  interval = 1
  maxcnt = 50
  pause = 2

  # Настройка логирования
  log_directory = "/home/logs"
  #log_directory = "./logs"
  logging.basicConfig(
    filename=os.path.join(log_directory, 'app.log'),
    level=logging.INFO
  )
  
  startTimerInterval(interval)
  
  backgroundTask(cnt, pause)

if __name__ == "__main__":  
  main()
